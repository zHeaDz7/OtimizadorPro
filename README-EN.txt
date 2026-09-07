OTIMIZADOR PRO (English overview)
==================================

What it is: a set of plain PowerShell scripts (no compiled .exe, nothing
hidden) that applies SAFE, OFFICIAL Windows/driver settings to improve
gaming performance on ANY game and ANY PC -- it is not tied to one
specific game or launcher. It auto-detects installed games via
Steam/Epic to apply exclusions and optimizations to them, and everything
else (RAM, CPU, GPU, disk, network, BIOS) works the same no matter what
you play.

Why plain-text scripts instead of a .exe: so you (or any customer of
yours) can open each .ps1 file in Notepad and read exactly what it does,
line by line, before running it. No serious optimization tool should
ask you to trust it blindly.

HOW TO USE
----------
Double-click "Otimizar.bat" (it will ask for Administrator permission --
several options need it). Pick an option from the menu, or press T to
run all the safe automatic ones at once.

WHAT IT COVERS
--------------
- Security: Windows Restore Point before making changes.
- Diagnostics (read-only): RAM/disk info, detected games, pagefile
  location, 14 extra hardware/network diagnostics (RAM channel mode,
  overlay detection, GPU driver age, Core Isolation/VBS, OneDrive sync,
  CPU throttling, third-party antivirus, gamepad latency, hybrid GPU,
  per-monitor refresh rate, laptop battery status, active VPN, Wi-Fi
  channel/signal, Fast Startup).
- System: Defender exclusions, Search indexing exclusions, Ultimate
  Performance power plan, Game Mode/Game Bar/visual effects, MMCSS
  gaming priority, network latency (Nagle, NIC power saving, Network
  Throttling Index, Large Send Offload), HAGS, fast DNS, audio
  enhancements off, SSD TRIM, Fullscreen Optimizations off, Windows
  telemetry off, monitor refresh rate check, Storage Sense, Delivery
  Optimization off.
- Network / ping / latency: ping diagnostic (router vs. internet),
  router-side tips guide (QoS, bufferbloat/SQM, Wi-Fi channel), NIC
  Interrupt Moderation, Winsock/TCP-IP repair tool.
- Advanced Registry (each shows current status and asks Apply/Revert/
  cancel before touching anything): true 1:1 mouse curve, USB Selective
  Suspend off, high-precision kernel timer, larger mouse/keyboard
  input queue, keep kernel/drivers in RAM (ISLC), disable accidental
  accessibility-shortcut popups, foreground CPU priority + per-game
  process priority, Core Parking off, GPU MSI Mode, GPU TDR Delay.
- Cleanup: deep clean (Temp, Prefetch, Recent, Windows Update cache,
  shader cache, Recycle Bin), HDD defragmentation (never SSD).
- Maintenance: instant RAM reclaim, mouse acceleration fix, heavy-
  process viewer (asks before closing anything), startup-item viewer
  (asks before disabling anything), GPU control-panel guide, BIOS/UEFI
  guide (XMP, Resizable BAR, Secure Boot, TPM, CSM, Fast Boot, C-States,
  PBO/MCE, fan curve).
- Tools & reports: preview status of every togglable item at once,
  0-100 optimization health score, Before/After report (real numbers,
  not marketing claims), "Undo everything" (reverts every advanced item
  back to Windows defaults in one go), full Windows Search pause,
  audit log of every change (with before/after values), session-log
  export for support.
- Keyword search: type a keyword and the menu shows which options match.

WHAT THIS TOOL NEVER DOES
--------------------------
- Never disables Windows Defender or Windows Update.
- Never replaces the operating system (unlike third-party "gamer
  Windows" ISOs -- those are unsupported, rebuilt images that can get
  blocked by game anti-cheat).
- Never claims cheat-like advantages ("less recoil," "perfect aim").
  This is hardware/system optimization, not an in-game edge.
- Never downloads or installs third-party software.
- Never closes programs or disables startup items on its own -- the
  process/startup tools always ask, item by item.

Every change is reversible through normal Windows settings, or through
the built-in "Undo everything" tool. Nothing here is permanent.

Full detailed documentation (Portuguese): LEIA-ME.txt
