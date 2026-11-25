# Distribution

```mermaid
flowchart TD
    subgraph repository["Repository lennartmoeller/agentic-plugins on GitHub, branch main"]
        marketplace[".claude-plugin/marketplace.json<br/>marketplace lennartmoeller, one entry per plugin with source ./plugins/name"]
        subgraph plugins["plugins/, each with .claude-plugin/plugin.json and icon.png"]
            ethos["ethos/<br/>skills/ with nine skills, context-authoring with scripts/context.sh and scripts/context.awk;<br/>hooks/ with hooks.json, rules.sh, guard.sh, instructions/ with session.md, subagent.md and shared.md"]
            house["empty-house-refactoring/<br/>skills/empty-house-refactoring/"]
            findings["list-github-findings/<br/>skills/list-github-findings/"]
        end
        installer["install.sh<br/>the plugin names, one requirement row per tool naming the plugins that need it, the settings to write"]
        release[".github/workflows/release.yml<br/>runs when started by hand"]
        marketplace --> ethos
        marketplace --> house
        marketplace --> findings
        release -->|"writes one version into every plugin.json, commits it to main and tags it v-version"| plugins
    end

    action["lennartmoeller/release-from-conventional-commits<br/>action pinned by commit"]
    action -->|"next version from the pull request titles since the last version,<br/>release commit, tag and GitHub release"| release

    claudesettings["A repository's .claude/settings.json<br/>extraKnownMarketplaces with autoUpdate, enabledPlugins with each plugin set up"]
    copilotsettings["A repository's .github/copilot/settings.json<br/>extraKnownMarketplaces, enabledPlugins with each plugin set up"]
    claude["Claude Code<br/>one cache per plugin at the version on main"]
    copilot["Copilot CLI<br/>plugin cache from main"]
    session["Session<br/>ethos skills as ethos:name and its hooks active,<br/>/empty-house-refactoring and /list-github-findings, each skill below its base directory"]
    run["install.sh run by a person in a repository<br/>curl -fsSL with its raw URL on main, piped to bash"]

    installer -->|"fetched by"| run
    run -->|"Claude Code chosen: marketplace with autoUpdate and every plugin set up or chosen, merged with jq"| claudesettings
    run -->|"claude plugin marketplace add and update, then install or update per plugin with --scope project"| claude
    run -->|"Copilot CLI chosen: marketplace and every plugin set up or chosen, merged with jq"| copilotsettings
    run -->|"copilot plugin marketplace update and update per plugin already installed"| copilot
    marketplace -->|"fetched by"| claude
    marketplace -->|"fetched by"| copilot
    claudesettings -->|"enables the plugins in that repository"| claude
    copilotsettings -->|"enables the plugins in that repository"| copilot
    claude -->|"loads skills and hooks into"| session
    copilot -->|"loads skills and hooks into"| session
```

A repository enables any combination of the three plugins, and a plugin's cache holds only its own folder under `plugins/`.

Claude Code moves a plugin's cache to `main` only when the version in its `plugin.json` differs from the cached one, and runs that update by itself because of `autoUpdate` on the marketplace entry: in the background, up to ten minutes after a session's first message, applied from the next start or `/reload-plugins`, while the installer runs it at once.
Copilot CLI ignores `autoUpdate` in a repository's settings, so it updates a plugin on `copilot plugin update`, which the installer runs, unless the person's own settings mark the marketplace `autoUpdate`.

Both tools put a skill's base directory, its folder in the plugin cache, above the skill's text, and the agent starts the skill's scripts from there through `sh`, with the repository as working directory.

Claude Code downloads a plugin that a repository enables only after one install per clone, which the installer runs, while Copilot CLI installs it once the folder is trusted.
The installer runs at the Git toplevel, asks about each plugin not yet set up for the chosen tool, updates each one already set up, lists only the requirements of those plugins, and fetches nothing beyond itself; [the README](../../README.md#installation) gives the one-liner.
