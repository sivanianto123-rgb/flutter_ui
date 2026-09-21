"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

export function WatchForm() {
  const router = useRouter();
  const [url, setUrl] = useState("");
  const [email, setEmail] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const response = await fetch("/api/monitors", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ url, email }),
      });
      const data = await response.json();

      if (!response.ok) {
        setError(data.error ?? "Something went wrong");
        return;
      }

      router.push(data.managePath);
    } catch {
      setError("Network error — try again");
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="watch-form">
      <label className="field">
        <span>Website URL</span>
        <input
          type="text"
          name="url"
          inputMode="url"
          autoComplete="url"
          placeholder="yourproduct.com"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          required
        />
      </label>
      <label className="field">
        <span>Email for alerts</span>
        <input
          type="email"
          name="email"
          autoComplete="email"
          placeholder="you@email.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </label>
      {error ? <p className="form-error">{error}</p> : null}
      <button type="submit" className="cta" disabled={loading}>
        {loading ? "Checking…" : "Watch this site"}
      </button>
      <p className="form-note">
        We’ll check it every few minutes and email you if it goes down.
      </p>
    </form>
  );
}
