# HideProcessCheat - NuGet WDK 版本

## 项目简介

这是一个使用 **NuGet 包安装 WDK** 的 Windows 内核驱动项目示例。

## 当前状态

| 状态 | 说明 |
|------|------|
| ✅ 源代码编译成功 | 使用 NuGet WDK 包 |
| ✅ 项目配置完成 | NuGet.config 和 packages.config |
| ⏳ 生成 .sys 驱动 | 需要完整 WDK 或 GitHub Actions |

## 项目结构

```
HideProcessesCheat-master\
├── .github\
│   └── workflows\
│       └── build.yml          ← GitHub Actions 配置
├── packages\
│   └── Microsoft.Windows.WDK.x64.10.0.26100.6584\
│       └── c\
│           ├── Include\10.0.26100.0\
│           │   ├── km\
│           │   └── shared\
│           └── Lib\10.0.26100.0\
├── .gitignore
├── Driver_mini.c              ← 驱动源代码
├── HideProcessMini.inf        ← 驱动安装文件
├── HideProcessMini.vcxproj    ← 项目文件
├── NuGet.config               ← NuGet 配置
└── packages.config            ← NuGet 包配置
```

## 使用 GitHub Actions 编译驱动

### 前置条件

1. 拥有 GitHub 账户
2. 将此项目推送到 GitHub 仓库

### 步骤

1. **推送代码到 GitHub**

   ```bash
   git init
   git add .
   git commit -m "Initial commit - Driver project with NuGet WDK"
   git remote add origin https://github.com/你的用户名/仓库名.git
   git push -u origin main
   ```

2. **查看构建结果**

   - 访问您的 GitHub 仓库
   - 点击 **Actions** 标签
   - 查看最新的工作流运行结果
   - 如果构建成功，在 **Artifacts** 部分下载 `driver-build`

3. **下载构建产物**

   - 在工作流运行详情页
   - 找到 **Artifacts** 部分
   - 点击 `driver-build` 下载
   - 解压查看生成的文件

## GitHub Actions 工作流说明

`.github/workflows/build.yml` 包含以下步骤：

| 步骤 | 说明 |
|------|------|
| Checkout repository | 克隆代码仓库 |
| Setup MSBuild | 配置 MSBuild 工具 |
| Setup NuGet | 配置 NuGet 工具 |
| Restore NuGet packages | 下载和恢复 NuGet 包 |
| Build driver | 编译驱动项目 |
| Upload build artifacts | 上传构建产物 |
| Check files | 列出文件以验证 |

## 本地构建（需要 WDK）

如果您有完整的 WDK，也可以本地构建：

```cmd
cd E:\HideProcessesCheat-master\HideProcessesCheat-master
nuget restore -PackagesDirectory ".\packages"
msbuild HideProcessMini.vcxproj /p:Configuration=Release /p:Platform=x64 /t:Rebuild
```

## 学习价值

此项目展示了：

1. **如何通过 NuGet 使用 WDK** - 无需完整安装 WDK
2. **GitHub Actions CI/CD** - 自动化驱动构建流程
3. **Windows 内核驱动开发基础** - DriverEntry 和相关 API

## 注意事项

⚠️ **重要提醒**：
- 这是一个学习项目，仅供教育目的
- 不要在生产环境使用
- 驱动需要数字签名才能在 Windows 上加载
- 错误的驱动代码可能导致系统蓝屏

## 下一步

- 使用 GitHub Actions 尝试编译
- 如果能获取完整 WDK，可以尝试完整构建
- 学习更多 Windows 驱动开发知识

## 相关资源

- [GitHub Actions 文档](https://docs.github.com/actions)
- [Windows Driver Kit 文档](https://learn.microsoft.com/en-us/windows-hardware/drivers/)
- [NuGet WDK 包](https://www.nuget.org/profiles/microsoft)