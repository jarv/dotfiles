# Herdr environment

OpenCode normally runs inside Herdr. At the start of each session, load the
`herdr` skill to understand the environment. Loading the skill does not authorize
inspecting or controlling other panes.

Before inspecting or controlling Herdr, verify that `HERDR_ENV=1`. If it is not
set to `1`, do not interact with Herdr.

Do not launch other agents or change terminal layout unless the user explicitly
requests it. Follow the Herdr skill's targeting and safety rules.
