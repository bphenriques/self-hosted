# Tailscale

I use Tailscale as it natively supports Synology devices.

## Basic Setup

1. Disable SSH access. I rather have that disabled, and it likely won't work as my servers use a different default port.
2. Enable device approval.

## Synology

1. Follow the Synology instructions: https://tailscale.com/kb/1131/synology
2. Add the `192.168.1.192/32` subnet so that only that IP is exposed. The same IP is being pointed by my domain.
3. Enable `Exit Node` so that all traffic goes through my NAS. Also enable exit node local network access.
4. Add firewall rule that grants networking within Tailscale: `100.64.0.0` (subnet mask `255.192.0.0`).
5. Approve the requests in the admin console.

## Access Control

Have this policy in-place that only grants access to my NAS exposed web-server and syncthing:
```json
{
  "grants": [
    // Home Server running on Synology NAS.
    {
      "src": ["autogroup:member"],
      "dst": ["192.168.1.192"],
      "ip":  ["tcp:443"],
    },

    // Syncthing file sharing running on Synology NAS. Access to specific folders is controlled by the service
    {
      "src": ["autogroup:member"],
      "dst": ["192.168.1.192"],
      "ip":  ["tcp:22000", "udp:22000"],
    },
  ],
}
```