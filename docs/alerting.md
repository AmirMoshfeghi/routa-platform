# Alerting for production

kube-prometheus-stack ships a strong set of default rules, and they're already active here. For production I wouldn't add a pile of new ones — I'd do the harder and more valuable work of deciding which alerts earn the right to page a human. The failure mode of most alerting setups isn't too few alerts; it's too many, until on-call stops trusting them. So my starting principle is blast radius and actionability: page only when something is customer-impacting and there's a clear action to take. Everything else warns or is left to dashboards.

I'd structure alerts in three tiers.

**Page immediately — the platform is down or about to be:**
- **etcd quorum loss or a member down.** This is the top of the list because it's the single point that can take the entire cluster with it. With a three-node control plane, losing one member is survivable, so I'd alert on the first loss as an early warning and escalate aggressively on the second — the gap between "degraded" and "down" is one node, and you want to be moving before you're in it.
- **API server unavailable or error rate climbing.** If the API is unhealthy, every other system — including your ability to deploy a fix — is compromised. This is the alert that determines whether an incident is ten minutes or two hours.
- **Node NotReady or unreachable.** On a GPU platform this is also a direct revenue signal: an unreachable node is paid-for capacity that isn't delivering, and depending on the customer it may be an SLA event, not just an ops one.
- **Certificate renewal failure.** Renewal is automated, but automation that fails silently is worse than no automation — you find out when TLS goes dark for customers. I'd alert on *renewal failure*, well ahead of expiry, not on expiry itself.

**Warn — needs attention, doesn't justify waking someone:**
- **Disk approaching capacity.** Prometheus TSDB, Harbor, and etcd all persist to node-local storage here, so a full disk isn't a performance problem, it's data corruption. But it's a slow-moving failure — hours of runway — so it's a warning with a clear remediation, not a page.
- **Workloads crash-looping or unschedulable.** Broken but contained. It waits for business hours unless the workload is itself a platform-critical component, in which case it graduates to the page tier.
- **Monitoring stack degraded.** If Prometheus or Alertmanager is unhealthy you're partially blind, which matters — but it's not customer-facing, and paging on your own observability going down tends to compound an incident rather than resolve it.

**Track, don't alert — capacity and trend signals:**
- Cluster-wide CPU, memory, and GPU utilization. These drive capacity planning and node-scaling decisions; they're dashboard material, and paging on them is how you train people to ignore pages.
- Per-tenant consumption in a multi-tenant platform — useful for catching a noisy neighbor or a tenant about to breach quota before it becomes someone else's incident, but it's a trend to watch, not an event to respond to.

The judgment that actually matters across all of this is restraint. Every alert that pages should carry an implicit runbook — if the responder can't do anything about it at 3am, it doesn't belong in the page tier. Ten alerts a team trusts are worth more than fifty they mute, and a muted alert is indistinguishable from no alert at all. I'd rather under-page and tune upward from real incidents than start noisy and erode trust in the whole system.

Routing follows the same tiering: I'd send the page tier to PagerDuty or Opsgenie so it actually wakes someone, warnings to a Slack channel the team watches during business hours, and everything silenced automatically during planned maintenance windows so a deploy doesn't page anyone for its own expected noise.

On a GPU cloud specifically, I'd extend this with DCGM-exporter-driven alerts — GPU temperature and ECC memory errors as hardware-health pages, and allocated-but-idle GPU time as a cost signal. Idle GPU capacity is the most expensive thing a platform like this can waste, so I'd treat utilization not just as a planning metric but as something worth surfacing to whoever owns the margin.
