# node-project-example
node app project example in typescript with package manager, dockerfile, ci script, semantic-release and lint set

## Environment

| Environment                   | Description                                                          |
| ----------------------------- | -------------------------------------------------------------------- |
| NODE_ENV                      | production, development                                              |
| DRY_RUN                       | set **true** to avoid any not read operations                        |

## development

1. 準備 node，版本比照 Dockerfile
1. 準備 yarn 3，參考官網以 node 自帶的 corepack 安裝；試著使用 pnp 零安裝，如有遇到所依賴 library 不支援時再切換回來
1. 配置 IDE 參考 [(Yarn)Editor SDKs](https://yarnpkg.com/getting-started/editor-sdks), 透過 .yarn/sdk 讓 IDE 如何找到本專案使用的 typescript, eslint, prettier 模組 (目前僅配置 vscode)
1. (windows) corepace 已知問題：`corepack prepare {pkgmanager}@{version} --activate` 安裝啟用包管理器，下載後路徑改名失敗導致找不到檔案，請參照 https://github.com/nodejs/corepack/issues/246 手動排除
