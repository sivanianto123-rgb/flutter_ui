import Link from "next/link";
import { notFound } from "next/navigation";
import { MonitorPanel } from "@/components/MonitorPanel";
import { getMonitorByToken } from "@/lib/monitors";

type Props = {
  params: Promise<{ token: string }>;
};

export default async function ManagePage({ params }: Props) {
  const { token } = await params;
  const monitor = await getMonitorByToken(token);

  if (!monitor) {
    notFound();
  }

  return (
    <div className="page-shell">
      <div className="page-inner manage-page">
        <nav className="site-nav">
          <Link className="brand" href="/">
            Pulse<span>Ping</span>
          </Link>
          <p className="nav-note">Private manage link</p>
        </nav>

        <MonitorPanel
          token={monitor.token}
          url={monitor.url}
          email={monitor.email}
          status={monitor.status}
          lastCheckedAt={monitor.lastCheckedAt}
          lastStatusCode={monitor.lastStatusCode}
          lastError={monitor.lastError}
        />
      </div>
    </div>
  );
}
