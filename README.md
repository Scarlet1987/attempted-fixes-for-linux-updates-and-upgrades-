# RX580_WAKE_FIX Display Sync

> **DISCLAIMER:** This software interacts directly with kernel modules (`drm_kms_helper`), `systemd` power targets, and hardware `udev` rules. It is provided **AS-IS** without warranty of any kind. Always inspect system scripts before running them with `sudo`.

---

A non-invasive, self-installing Linux hardware-wake utility designed to resolve display wake-up failures on systems driving mixed monitors and sleeping TVs (specifically tuned for AMD Polaris / RX 580 GPUs on Pop!_OS).

## Features
- **Self-Installing & Self-Cleaning:** Integrated `--install`, `--destroy`, and `--status` flags.
- **Kernel-Level Polling:** Triggers `drm_kms_helper.poll=1` to wake sleeping HDMI EDID chips without crashing the desktop compositor.
- **Tagged Removal:** Includes a `RX580_WAKE_FIX` tag for clean system cleanup.  

## Installation & Usage

```bash
# 1. Download script directly
curl -sSL [https://raw.githubusercontent.com/YOUR_USERNAME/display-sync-rx580/main/display-sync.sh](https://raw.githubusercontent.com/YOUR_USERNAME/display-sync-rx580/main/display-sync.sh) -o display-sync.sh

# 2. Make executable & move to system path
chmod +x display-sync.sh
sudo mv display-sync.sh /usr/local/bin/display-sync.sh

# 3. Install system hooks
sudo /usr/local/bin/display-sync.sh --install

# 4. Check installation status
/usr/local/bin/display-sync.sh --status
```

## Uninstallation (Search & Destroy)

If a driver conflict occurs or you want to restore default system behavior, run:

```bash
sudo /usr/local/bin/display-sync.sh --destroy
sudo rm /usr/local/bin/display-sync.sh
```

---

## Legal & Warranty

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
