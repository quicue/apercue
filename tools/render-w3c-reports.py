#!/usr/bin/env python3
"""Render W3C CG report markdown files to standalone HTML pages.

Produces clean, professional HTML suitable for sharing with W3C Community
Groups. Each report becomes a standalone page in site/w3c/.

Usage:
    python3 tools/render-w3c-reports.py          # render all reports
    python3 tools/render-w3c-reports.py --list    # list available reports
"""

import sys
import os
from pathlib import Path

try:
    import markdown
except ImportError:
    print("pip install markdown", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = Path(__file__).resolve().parent.parent
W3C_DIR = REPO_ROOT / "w3c"
OUT_DIR = REPO_ROOT / "site" / "w3c"

# Reports to render (filename without .md → output slug)
REPORTS = {
    "core-report": "Core W3C Evidence Report",
    "context-graphs": "Context Graphs CG Report",
    "kg-construct": "KG-Construct CG Report",
    "dataspaces": "Dataspaces CG Report",
    "pm-kr": "PM-KR CG Report",
}

HTML_TEMPLATE = """\
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — apercue.ca</title>
<style>
  :root {{
    --bg: #fafafa;
    --fg: #1a1a1a;
    --accent: #2563eb;
    --code-bg: #f3f4f6;
    --border: #d1d5db;
    --max-w: 48rem;
  }}
  @media (prefers-color-scheme: dark) {{
    :root {{
      --bg: #111827;
      --fg: #e5e7eb;
      --accent: #60a5fa;
      --code-bg: #1f2937;
      --border: #374151;
    }}
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
    background: var(--bg);
    color: var(--fg);
    line-height: 1.7;
    padding: 2rem 1rem;
    max-width: var(--max-w);
    margin: 0 auto;
  }}
  nav {{
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--border);
    font-size: 0.875rem;
  }}
  nav a {{ color: var(--accent); text-decoration: none; }}
  nav a:hover {{ text-decoration: underline; }}
  h1 {{ font-size: 1.75rem; margin: 1.5rem 0 0.75rem; }}
  h2 {{ font-size: 1.35rem; margin: 1.5rem 0 0.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.25rem; }}
  h3 {{ font-size: 1.1rem; margin: 1.25rem 0 0.5rem; }}
  p {{ margin: 0.75rem 0; }}
  a {{ color: var(--accent); }}
  ul, ol {{ margin: 0.75rem 0 0.75rem 1.5rem; }}
  li {{ margin: 0.25rem 0; }}
  code {{
    background: var(--code-bg);
    padding: 0.15em 0.4em;
    border-radius: 3px;
    font-size: 0.9em;
    font-family: "SF Mono", "Fira Code", Consolas, monospace;
  }}
  pre {{
    background: var(--code-bg);
    padding: 1rem;
    border-radius: 6px;
    overflow-x: auto;
    margin: 1rem 0;
    border: 1px solid var(--border);
  }}
  pre code {{
    background: none;
    padding: 0;
    font-size: 0.85em;
    line-height: 1.5;
  }}
  blockquote {{
    border-left: 3px solid var(--accent);
    padding-left: 1rem;
    margin: 1rem 0;
    color: #6b7280;
  }}
  table {{
    border-collapse: collapse;
    width: 100%;
    margin: 1rem 0;
    font-size: 0.9rem;
  }}
  th, td {{
    border: 1px solid var(--border);
    padding: 0.5rem 0.75rem;
    text-align: left;
  }}
  th {{ background: var(--code-bg); font-weight: 600; }}
  hr {{ border: none; border-top: 1px solid var(--border); margin: 1.5rem 0; }}
  strong {{ font-weight: 600; }}
  .meta {{
    color: #6b7280;
    font-size: 0.875rem;
    margin-top: 3rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border);
  }}
</style>
</head>
<body>
<nav>
  <a href="../index.html">apercue.ca</a> /
  <a href="index.html">W3C Reports</a> /
  {title}
</nav>
{content}
<div class="meta">
  <p>Source: <a href="https://github.com/quicue/apercue/tree/main/w3c">github.com/quicue/apercue/tree/main/w3c</a></p>
  <p>All evidence is computed from CUE source. Reproduce: <code>cue export ./w3c/ -e evidence --out json</code></p>
</div>
</body>
</html>
"""

INDEX_TEMPLATE = """\
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>W3C Community Group Reports — apercue.ca</title>
<style>
  :root {{
    --bg: #fafafa;
    --fg: #1a1a1a;
    --accent: #2563eb;
    --code-bg: #f3f4f6;
    --border: #d1d5db;
  }}
  @media (prefers-color-scheme: dark) {{
    :root {{
      --bg: #111827;
      --fg: #e5e7eb;
      --accent: #60a5fa;
      --code-bg: #1f2937;
      --border: #374151;
    }}
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: var(--bg);
    color: var(--fg);
    line-height: 1.7;
    padding: 2rem 1rem;
    max-width: 48rem;
    margin: 0 auto;
  }}
  nav {{ margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid var(--border); font-size: 0.875rem; }}
  nav a {{ color: var(--accent); text-decoration: none; }}
  nav a:hover {{ text-decoration: underline; }}
  h1 {{ font-size: 1.75rem; margin-bottom: 0.5rem; }}
  .subtitle {{ color: #6b7280; margin-bottom: 2rem; }}
  .reports {{ list-style: none; padding: 0; }}
  .reports li {{
    margin: 0.75rem 0;
    padding: 1rem;
    border: 1px solid var(--border);
    border-radius: 6px;
    transition: border-color 0.15s;
  }}
  .reports li:hover {{ border-color: var(--accent); }}
  .reports a {{ color: var(--accent); text-decoration: none; font-weight: 600; font-size: 1.05rem; }}
  .reports a:hover {{ text-decoration: underline; }}
  .reports .desc {{ color: #6b7280; font-size: 0.9rem; margin-top: 0.25rem; }}
</style>
</head>
<body>
<nav><a href="../index.html">apercue.ca</a> / W3C Reports</nav>
<h1>W3C Community Group Reports</h1>
<p class="subtitle">Implementation evidence for compile-time linked data patterns</p>
<ul class="reports">
{report_list}
</ul>
<p style="margin-top:2rem;color:#6b7280;font-size:0.875rem;">
  Source: <a href="https://github.com/quicue/apercue/tree/main/w3c" style="color:var(--accent)">github.com/quicue/apercue/tree/main/w3c</a>
</p>
</body>
</html>
"""

REPORT_DESCRIPTIONS = {
    "core-report": "Full W3C evidence — 14 spec outputs from a single CUE value, computed live from a research pipeline graph.",
    "context-graphs": "Implementation report for the W3C Context Graphs Community Group — named graph federation via CUE unification.",
    "kg-construct": "Implementation report for the KG-Construct Community Group — typed DAG construction and W3C projection.",
    "dataspaces": "Implementation report for the Dataspaces Community Group — ODRL policy enforcement and DCAT catalog generation.",
    "pm-kr": "Implementation report for the PM-KR Community Group — critical path scheduling with OWL-Time and PROV-O.",
}


def render_report(slug: str, title: str) -> None:
    """Render a single markdown report to HTML."""
    src = W3C_DIR / f"{slug}.md"
    if not src.exists():
        print(f"  SKIP: {src} not found", file=sys.stderr)
        return

    md_text = src.read_text()
    html_body = markdown.markdown(
        md_text,
        extensions=["fenced_code", "tables", "toc"],
        output_format="html",
    )
    full_html = HTML_TEMPLATE.format(title=title, content=html_body)

    out_path = OUT_DIR / f"{slug}.html"
    out_path.write_text(full_html)
    print(f"  {out_path.relative_to(REPO_ROOT)} ({len(md_text)} chars)")


def render_index() -> None:
    """Render the report index page."""
    items = []
    for slug, title in REPORTS.items():
        desc = REPORT_DESCRIPTIONS.get(slug, "")
        items.append(
            f'<li><a href="{slug}.html">{title}</a>'
            f'<div class="desc">{desc}</div></li>'
        )
    html = INDEX_TEMPLATE.format(report_list="\n".join(items))
    out_path = OUT_DIR / "index.html"
    out_path.write_text(html)
    print(f"  {out_path.relative_to(REPO_ROOT)} (index)")


def main():
    if "--list" in sys.argv:
        for slug, title in REPORTS.items():
            print(f"  {slug}: {title}")
        return

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print("Rendering W3C CG reports to HTML...")

    for slug, title in REPORTS.items():
        render_report(slug, title)

    render_index()
    print(f"Done. {len(REPORTS)} reports + index in site/w3c/")


if __name__ == "__main__":
    main()
