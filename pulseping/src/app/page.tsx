import { WatchForm } from "@/components/WatchForm";

type Props = {
  searchParams: Promise<{ removed?: string }>;
};

export default async function Home({ searchParams }: Props) {
  const params = await searchParams;

  return (
    <div className="page-shell">
      <div className="page-inner">
        <nav className="site-nav">
          <a className="brand" href="/">
            Pulse<span>Ping</span>
          </a>
          <p className="nav-note">Uptime alerts by email</p>
        </nav>

        {params.removed ? (
          <p className="banner">Monitor removed. Add another anytime.</p>
        ) : null}

        <section className="hero">
          <div className="hero-copy">
            <h1 className="brand-hero">
              Pulse<em>Ping</em>
            </h1>
            <p className="hero-sub">
              Tell us a website and an email. We ping it on a schedule and write
              you the moment it goes dark.
            </p>
            <WatchForm />
          </div>

          <div className="hero-visual" aria-hidden>
            <div className="pulse-stage">
              <div className="ring" />
              <div className="ring" />
              <div className="ring" />
              <div className="signal-line" />
              <div className="pulse-core">
                <strong>Live</strong>
              </div>
            </div>
          </div>
        </section>

        <section className="how">
          <h2>How it works</h2>
          <p>No account. One URL. Email when something breaks.</p>
          <ol className="steps">
            <li>
              <strong>Add a site</strong>
              <p>Paste any public URL and the inbox that should get alerts.</p>
            </li>
            <li>
              <strong>We keep pinging</strong>
              <p>A cron job checks every few minutes and tracks up / down.</p>
            </li>
            <li>
              <strong>You get the email</strong>
              <p>Down alerts and recovery notes, plus a private manage link.</p>
            </li>
          </ol>
        </section>

        <footer className="site-footer">
          PulsePing · built to ship in an afternoon
        </footer>
      </div>
    </div>
  );
}
