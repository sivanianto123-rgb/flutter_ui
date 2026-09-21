(() => {
  const OWNER = "sivanianto123-rgb";
  const REPO = "flutter_ui";
  const BRANCH = "main";
  const EXCLUDED_ROOTS = ["reading_app"]; // company project, shown separately

  const galleryEl = document.getElementById("gallery");

  function setStatus(message, isError = false) {
    galleryEl.innerHTML = `<p class="status${isError ? " error" : ""}">${escapeHtml(message)}</p>`;
  }

  function escapeHtml(str) {
    const div = document.createElement("div");
    div.textContent = str;
    return div.innerHTML;
  }

  function titleCase(str) {
    return str
      .trim()
      .split(/[-_]+/)
      .filter(Boolean)
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(" ");
  }

  function encodeGithubPath(path) {
    return path.split("/").map(encodeURIComponent).join("/");
  }

  function isExcluded(path) {
    return EXCLUDED_ROOTS.some(
      (root) => path === root || path.startsWith(`${root}/`)
    );
  }

  async function fetchJson(url) {
    const res = await fetch(url, {
      headers: { Accept: "application/vnd.github+json" },
    });
    if (!res.ok) {
      const err = new Error(`Request failed: ${res.status}`);
      err.status = res.status;
      throw err;
    }
    return res.json();
  }

  function buildEntries(tree) {
    const blobPaths = new Set(
      tree.filter((item) => item.type === "blob").map((item) => item.path)
    );

    const projectRoots = new Set();

    for (const path of blobPaths) {
      if (path.endsWith("/pubspec.yaml") && !isExcluded(path)) {
        projectRoots.add(path.slice(0, -"/pubspec.yaml".length));
      }
    }
    if (blobPaths.has("to_do_list/package.json") && !isExcluded("to_do_list")) {
      projectRoots.add("to_do_list");
    }

    const entries = [];

    for (const root of projectRoots) {
      const segments = root.split("/");
      const lastSegment = segments[segments.length - 1];
      const parentSegment = segments.length > 1 ? segments[segments.length - 2] : null;

      const isReact = root === "to_do_list";

      entries.push({
        title: titleCase(lastSegment),
        tag: parentSegment ? titleCase(parentSegment) : null,
        tech: isReact ? "React" : "Flutter",
        htmlUrl: `https://github.com/${OWNER}/${REPO}/tree/${BRANCH}/${encodeGithubPath(root)}`,
      });
    }

    entries.sort((a, b) => a.title.localeCompare(b.title));
    return entries;
  }

  function renderCards(entries) {
    if (entries.length === 0) {
      galleryEl.innerHTML = `
        <div class="empty-state">
          <h2>New screens go up here regularly</h2>
          <p>Check back soon — or browse the repo directly on
            <a href="https://github.com/${OWNER}/${REPO}" style="color: var(--accent)">GitHub</a>.
          </p>
        </div>`;
      return;
    }

    galleryEl.innerHTML = entries
      .map(
        (entry) => `
      <a class="card" href="${entry.htmlUrl}" target="_blank" rel="noopener">
        <div class="card-body">
          ${entry.tag ? `<p class="card-tag">${escapeHtml(entry.tag)}</p>` : ""}
          <p class="card-title">${escapeHtml(entry.title)}</p>
          <span class="card-tech">${escapeHtml(entry.tech)}</span>
        </div>
        <div class="card-link">
          View on GitHub
          <svg viewBox="0 0 16 16" width="13" height="13" aria-hidden="true">
            <path fill="currentColor" d="M6 3a.75.75 0 0 1 .75-.75h5.5A.75.75 0 0 1 13 3v5.5a.75.75 0 0 1-1.5 0V4.81L4.03 12.28a.75.75 0 0 1-1.06-1.06L10.44 3.5H6.75A.75.75 0 0 1 6 3Z" />
          </svg>
        </div>
      </a>`
      )
      .join("");
  }

  async function main() {
    let tree;
    try {
      const data = await fetchJson(
        `https://api.github.com/repos/${OWNER}/${REPO}/git/trees/${BRANCH}?recursive=1`
      );
      tree = data.tree;
    } catch (err) {
      if (err.status === 403) {
        setStatus(
          "GitHub API rate limit reached — try refreshing in a bit, or browse the repo directly.",
          true
        );
      } else {
        setStatus("Couldn't load projects right now. Please try again shortly.", true);
      }
      return;
    }

    renderCards(buildEntries(tree));
  }

  main();
})();
