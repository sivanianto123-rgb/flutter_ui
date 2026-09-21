import Link from "next/link";

export default function NotFound() {
  return (
    <div className="page-shell">
      <div className="page-inner">
        <nav className="site-nav">
          <Link className="brand" href="/">
            Pulse<span>Ping</span>
          </Link>
        </nav>
        <div className="empty-state">
          <h1>Monitor not found</h1>
          <p>This manage link is invalid or the monitor was removed.</p>
          <p style={{ marginTop: "1.5rem" }}>
            <Link className="cta" href="/" style={{ display: "inline-block" }}>
              Watch a new site
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
