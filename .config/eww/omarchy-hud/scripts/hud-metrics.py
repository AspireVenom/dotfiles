#!/usr/bin/env python3

"""Stream JSON metrics for the Omarchy HUD overlay."""

from __future__ import annotations

import json
import os
import pathlib
import subprocess
import time
from typing import Any, Dict, List, Optional, Tuple

STATE_DIR = pathlib.Path.home() / ".local/state/omarchy"
MODE_FILE = STATE_DIR / "mode"
NET_HISTORY_LEN = 24
GRAPH_CHARS = " .:-=+*#%@"


def run_cmd(cmd: List[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def get_gpu_stats() -> Dict[str, Any]:
    stats = {
        "gpu_usage": None,
        "vram_used": None,
        "vram_total": None,
        "vram_percent": None,
        "temperature": None,
    }

    result = run_cmd(
        [
            "nvidia-smi",
            "--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu",
            "--format=csv,noheader,nounits",
        ]
    )
    if result.returncode == 0 and result.stdout.strip():
        line = result.stdout.strip().splitlines()[0]
        parts = [p.strip() for p in line.split(",")]
        if len(parts) >= 4:
            try:
                usage = float(parts[0])
                vram_used = float(parts[1])
                vram_total = float(parts[2])
                temp = float(parts[3])
            except ValueError:
                pass
            else:
                stats["gpu_usage"] = usage
                stats["vram_used"] = vram_used
                stats["vram_total"] = vram_total
                if vram_total:
                    stats["vram_percent"] = round((vram_used / vram_total) * 100, 1)
                stats["temperature"] = temp
                return stats

    # Fallback to kernel counters for other GPUs
    busy_path = pathlib.Path("/sys/class/drm/card0/device/gpu_busy_percent")
    if busy_path.exists():
        try:
            stats["gpu_usage"] = float(busy_path.read_text().strip())
        except ValueError:
            stats["gpu_usage"] = None

    mem_used = pathlib.Path("/sys/class/drm/card0/device/mem_info_vram_used")
    mem_total = pathlib.Path("/sys/class/drm/card0/device/mem_info_vram_total")
    if mem_used.exists() and mem_total.exists():
        try:
            used = int(mem_used.read_text().strip()) / (1024 * 1024)
            total = int(mem_total.read_text().strip()) / (1024 * 1024)
        except ValueError:
            pass
        else:
            stats["vram_used"] = round(used, 1)
            stats["vram_total"] = round(total, 1)
            if total:
                stats["vram_percent"] = round((used / total) * 100, 1)

    temp_path = pathlib.Path("/sys/class/drm/card0/device/hwmon/hwmon0/temp1_input")
    if temp_path.exists():
        try:
            stats["temperature"] = int(temp_path.read_text().strip()) / 1000.0
        except ValueError:
            stats["temperature"] = None

    return stats


def hypr_json(args: List[str]) -> Optional[Dict[str, Any]]:
    result = run_cmd(["hyprctl", *args, "-j"])
    if result.returncode == 0 and result.stdout.strip():
        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError:
            return None
    return None


def get_workspace() -> Dict[str, Any]:
    data = hypr_json(["activeworkspace"]) or {}
    return {"workspace_id": data.get("id"), "workspace_name": data.get("name")}


def get_fps() -> Optional[float]:
    result = run_cmd(["hyprctl", "monitors", "-j"])
    if result.returncode != 0 or not result.stdout.strip():
        return None
    try:
        monitors = json.loads(result.stdout)
    except json.JSONDecodeError:
        return None
    if not monitors:
        return None
    fps = monitors[0].get("refreshRate")
    return round(float(fps), 1) if fps else None


def get_git_branch() -> Dict[str, Optional[str]]:
    active = hypr_json(["activewindow"]) or {}
    pid = active.get("pid")
    if not pid:
        return {"branch": None, "repo": None, "path": None}
    cwd_link = pathlib.Path(f"/proc/{pid}/cwd")
    try:
        real_cwd = cwd_link.resolve(strict=True)
    except FileNotFoundError:
        return {"branch": None, "repo": None, "path": None}

    git_dir = real_cwd
    while git_dir != git_dir.parent:
        if (git_dir / ".git").exists():
            branch = (
                run_cmd(["git", "-C", str(git_dir), "rev-parse", "--abbrev-ref", "HEAD"])
                .stdout.strip()
            )
            repo = git_dir.name
            branch = branch if branch else None
            return {"branch": branch, "repo": repo, "path": str(git_dir)}
        git_dir = git_dir.parent
    return {"branch": None, "repo": None, "path": str(real_cwd)}


def get_notifications() -> Dict[str, Any]:
    result = run_cmd(["makoctl", "list", "-j"])
    if result.returncode != 0 or not result.stdout.strip():
        return {"count": 0, "last_summary": None}
    try:
        notifications = json.loads(result.stdout)
    except json.JSONDecodeError:
        return {"count": 0, "last_summary": None}
    count = len(notifications)
    last_summary = notifications[-1]["summary"] if notifications else None
    return {"count": count, "last_summary": last_summary}


def get_mode() -> str:
    try:
        return MODE_FILE.read_text().strip()
    except FileNotFoundError:
        MODE_FILE.parent.mkdir(parents=True, exist_ok=True)
        MODE_FILE.write_text("coding\n")
        return "coding"


def get_compile_status() -> Dict[str, str]:
    pattern = (
        "cargo build|cargo check|pnpm build|pnpm dev|npm run|npm run build|"
        "yarn build|bun build|tsc|make|ninja|gradle|go build|uv run|just build|cmake --build"
    )
    result = run_cmd(["pgrep", "-fal", pattern])
    if result.returncode == 0 and result.stdout.strip():
        detail = result.stdout.strip().splitlines()[0]
        return {"status": "building", "detail": detail}
    return {"status": "idle", "detail": "idle"}


class NetStats:
    def __init__(self) -> None:
        self.iface = self._detect_iface()
        self.prev = self._read_bytes()
        self.history_down: List[float] = [0.0] * NET_HISTORY_LEN
        self.history_up: List[float] = [0.0] * NET_HISTORY_LEN
        self.prev_time = time.time()

    def _detect_iface(self) -> Optional[str]:
        result = run_cmd(["ip", "route", "show", "default"])
        if result.returncode == 0 and result.stdout.strip():
            parts = result.stdout.split()
            if "dev" in parts:
                idx = parts.index("dev")
                if idx + 1 < len(parts):
                    return parts[idx + 1]
        candidates = sorted(
            p.name for p in pathlib.Path("/sys/class/net").iterdir() if p.name != "lo"
        )
        return candidates[0] if candidates else None

    def _read_bytes(self) -> Tuple[int, int]:
        if not self.iface:
            return (0, 0)
        rx_path = pathlib.Path(f"/sys/class/net/{self.iface}/statistics/rx_bytes")
        tx_path = pathlib.Path(f"/sys/class/net/{self.iface}/statistics/tx_bytes")
        try:
            rx = int(rx_path.read_text().strip())
            tx = int(tx_path.read_text().strip())
            return (rx, tx)
        except FileNotFoundError:
            return (0, 0)

    def poll(self) -> Dict[str, Any]:
        now = time.time()
        rx, tx = self._read_bytes()
        dt = now - self.prev_time if now > self.prev_time else 1.0
        drx = max(rx - self.prev[0], 0)
        dtx = max(tx - self.prev[1], 0)
        down_mbps = (drx * 8) / (dt * 1_000_000)
        up_mbps = (dtx * 8) / (dt * 1_000_000)

        self.history_down.append(down_mbps)
        self.history_up.append(up_mbps)
        if len(self.history_down) > NET_HISTORY_LEN:
            self.history_down.pop(0)
        if len(self.history_up) > NET_HISTORY_LEN:
            self.history_up.pop(0)

        self.prev = (rx, tx)
        self.prev_time = now

        return {
            "iface": self.iface,
            "down_mbps": round(down_mbps, 2),
            "up_mbps": round(up_mbps, 2),
            "down_graph": self._graph(self.history_down),
            "up_graph": self._graph(self.history_up),
        }

    def _graph(self, history: List[float]) -> str:
        max_val = max(history) or 1.0
        buckets = len(GRAPH_CHARS) - 1
        chars = []
        for value in history:
            scaled = int((value / max_val) * buckets) if max_val else 0
            chars.append(GRAPH_CHARS[min(scaled, buckets)])
        return "".join(chars)


def main() -> None:
    net = NetStats()
    while True:
        gpu = get_gpu_stats()
        workspace = get_workspace()
        fps = get_fps()
        git_info = get_git_branch()
        notifications = get_notifications()
        mode = get_mode()
        compile_status = get_compile_status()
        network = net.poll()

        payload = {
            "gpu": gpu,
            "workspace": workspace,
            "fps": fps,
            "git": git_info,
            "notifications": notifications,
            "mode": mode,
            "compile": compile_status,
            "network": network,
            "timestamp": time.time(),
        }
        print(json.dumps(payload), flush=True)
        time.sleep(1)


if __name__ == "__main__":
    main()

