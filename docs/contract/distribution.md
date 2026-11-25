# Distribution

```mermaid
flowchart TD
    subgraph repository["Repository lennartmoeller/agentic-plugins on GitHub, branch main"]
        marketplace[".claude-plugin/marketplace.json<br/>marketplace lennartmoeller, one plugin with source ./"]
        manifest[".claude-plugin/plugin.json<br/>plugin agentic with its version"]
        skills["skills/<br/>one folder per skill"]
        contextskill["skills/context-authoring/<br/>SKILL.md, scripts/context.sh and scripts/context.awk"]
        hooks["hooks/<br/>hooks.json, rules.sh, guard.sh, instructions/ with session.md, subagent.md and shared.md"]
        installer["install.sh<br/>the skills' combined requirements, the settings to write"]
        release[".github/workflows/release.yml<br/>runs when started by hand"]
        marketplace --> manifest
        manifest --> skills
        skills --- contextskill
        manifest --> hooks
        release -->|"writes the version, commits it to main and tags it v-version"| manifest
    end

    action["lennartmoeller/release-from-conventional-commits<br/>action pinned by commit"]
    action -->|"next version from the pull request titles since the last version,<br/>release commit, tag and GitHub release"| release

    claudesettings["A repository's .claude/settings.json<br/>extraKnownMarketplaces with autoUpdate, enabledPlugins"]
    copilotsettings["A repository's .github/copilot/settings.json<br/>extraKnownMarketplaces, enabledPlugins"]
    claude["Claude Code<br/>plugin cache at the version on main"]
    copilot["Copilot CLI<br/>plugin cache from main"]
    session["Session<br/>skills as agentic:name, each below its base directory, hooks active"]
    run["install.sh run by a person in a repository<br/>curl -fsSL with its raw URL on main, piped to bash"]

    installer -->|"fetched by"| run
    run -->|"Claude Code chosen: marketplace with autoUpdate and plugin, merged with jq"| claudesettings
    run -->|"claude plugin marketplace add and install, or update, with --scope project"| claude
    run -->|"Copilot CLI chosen: marketplace and plugin, merged with jq"| copilotsettings
    run -->|"copilot plugin update, once installed"| copilot
    marketplace -->|"fetched by"| claude
    marketplace -->|"fetched by"| copilot
    claudesettings -->|"enables the plugin in that repository"| claude
    copilotsettings -->|"enables the plugin in that repository"| copilot
    claude -->|"loads skills and hooks into"| session
    copilot -->|"loads skills and hooks into"| session
```

Claude Code moves its cache to `main` only when the version in `plugin.json` differs from the cached one, and runs that update by itself because of `autoUpdate` on the marketplace entry: in the background, up to ten minutes after a session's first message, applied from the next start or `/reload-plugins`, while the installer runs it at once.
Copilot CLI ignores `autoUpdate` in a repository's settings, so it updates the plugin on `copilot plugin update`, which the installer runs, unless the person's own settings mark the marketplace `autoUpdate`.

Both tools put a skill's base directory, its folder in the plugin cache, above the skill's text, and the agent starts the skill's scripts from there through `sh`, with the repository as working directory.

Claude Code downloads a plugin that a repository enables only after one install per clone, which the installer runs, while Copilot CLI installs it once the folder is trusted.
The installer runs at the Git toplevel and fetches nothing beyond itself; [the README](../../README.md#installation) gives the one-liner.
