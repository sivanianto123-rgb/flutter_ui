(() => {
  const OWNER = "sivanianto123-rgb";
  const REPO = "flutter_ui";
  const BRANCH = "main";
  const IMAGE_EXTENSIONS = [".png", ".jpg", ".jpeg", ".webp", ".gif"];
  const EXCLUDED_ROOTS = ["reading_app"]; // company project, shown separately

  const galleryEl = document.getElementById("gallery");

  // soft backdrop tints behind each phone, picked per project so the grid has some rhythm
  const GLOWS = ["#2997ff", "#a259ff", "#ff7a59", "#2fd6a3", "#ffc53d", "#ff5c8a"];

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

  function hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = (hash * 31 + str.charCodeAt(i)) >>> 0;
    }
    return hash;
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

      const screenshotPath = [...blobPaths].find(
        (path) =>
          path.startsWith(`${root}/`) &&
          !path.slice(root.length + 1).includes("/") &&
          IMAGE_EXTENSIONS.some((ext) => path.toLowerCase().endsWith(ext))
      );

      const isReact = root === "to_do_list";

      entries.push({
        title: titleCase(lastSegment),
        tag: parentSegment ? titleCase(parentSegment) : null,
        tech: isReact ? "React" : "Flutter",
        htmlUrl: `https://github.com/${OWNER}/${REPO}/tree/${BRANCH}/${encodeGithubPath(root)}`,
        imageUrl: screenshotPath
          ? `https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${encodeGithubPath(screenshotPath)}`
          : null,
        glow: GLOWS[hashString(root) % GLOWS.length],
      });
    }

    entries.sort((a, b) => a.title.localeCompare(b.title));
    // only show projects that have a real UI screenshot to look at
    return entries.filter((entry) => entry.imageUrl);
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
      .map((entry) => {
        const media = `<div class="card-image-wrap" style="--glow:${entry.glow}">
               <img src="${entry.imageUrl}" alt="${escapeHtml(entry.title)} screen" loading="lazy" />
             </div>`;

        return `
      <a class="card" href="${entry.htmlUrl}" target="_blank" rel="noopener">
        ${media}
        <div class="card-body">
          ${entry.tag ? `<p class="card-tag">${escapeHtml(entry.tag)}</p>` : ""}
          <p class="card-title">${escapeHtml(entry.title)}</p>
          <span class="card-tech">${escapeHtml(entry.tech)}</span>
        </div>
      </a>`;
      })
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
