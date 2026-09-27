# Codex DeskPet for DeepSeek Harness

为 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 打造的 macOS、Windows 和 Linux 桌面宠物，**全面兼容 Codex 宠物生态**。让喜欢的角色陪你工作，也陪你等待任务完成。

[English](README.md)

## 功能

- 在 DeepSeek Harness 的“设置”中增加独立的“桌面宠物”栏目。
- 宠物常驻桌面，可以自由拖动。
- 双击宠物即可回到已经打开的 Harness 页面。
- 单击触发随机动作和自定义快捷语。
- 任务运行或等待确认时，在宠物上方显示当前任务。
- 大小、位置、显示状态、当前宠物和快捷语均会保存。
- 中文与英文界面跟随 DeepSeek Harness 当前语言。
- **兼容所有 Codex 宠物仓库**，下载后即可切换和使用。
- 已直接集成 Awesome Codex Pet、Codex Pets、PetDex、SpriteYard、AgentBro、OpenPets 和 Codex Anime Pets，可在线查找、下载与更新。
- 宠物商店支持搜索、筛选和滚动自动加载。

## 界面预览

### 中文桌宠设置

![中文桌宠设置](docs/images/desktop-pet-settings-zh.jpg)

### 英文桌宠设置

![英文桌宠设置](docs/images/desktop-pet-settings-en.jpg)

### 中文宠物商店

![宠物商店](docs/images/pet-store-zh.jpg)

### 英文宠物商店

![英文宠物商店](docs/images/pet-store-en.png)

## 默认宠物

默认宠物为 BongoCat。

## 环境要求

- macOS 13 或更高版本、Windows 10/11，或现代桌面 Linux 发行版
- Git

其他需要的组件会由安装器自动准备。

## 安装

### macOS 和 Linux

```bash
git clone https://github.com/yihanz0107/codex-deskpet-for-deepseek-harness.git
cd codex-deskpet-for-deepseek-harness
./install.sh
```

### Windows（PowerShell）

```powershell
git clone https://github.com/yihanz0107/codex-deskpet-for-deepseek-harness.git
cd codex-deskpet-for-deepseek-harness
.\install.ps1
```

安装器会自动检测操作系统并找到 DeepSeek Harness；如果还没有安装，也会一并准备好。

## 启动

```bash
deepsshpet
```

该命令不是只启动宠物：它会启动桌宠和 DeepSeek Harness。若 Harness 已经在运行，则直接聚焦现有页面，不会重复启动服务。

首次启动如果还没有 API Key，会先提示输入。

同时关闭 DeepSeek Harness 和桌宠：

```bash
deepsshpet stop
```

## 使用

打开 DeepSeek Harness → 设置 → 桌面宠物：

- “我的宠物”用于切换或删除已经安装的宠物。
- “找找新宠物”打开全屏宠物商店。
- 可以自由调节宠物大小。
- “宠物快捷语”每行一句，保存后单击宠物会随机显示。
- 动画状态默认为自动跟随任务，也可以手动固定。

桌面操作：

- 鼠标移入：挥手。
- 单击：随机动作和快捷语。
- 拖动：移动宠物。
- 双击：返回已经打开的 Harness 页面。
- 右键：挥手、隐藏或退出桌宠。

## 许可证

本项目代码采用 MIT License。第三方宠物图像、人物和商标仍属于各自权利人，详见 [THIRD_PARTY_PETS.md](THIRD_PARTY_PETS.md)。

## 宠物来源与感谢

特别感谢 [ayangweb/bongocat](https://github.com/ayangweb/bongocat) 以及 BongoCat 的创作者与贡献者。之所以有这个项目，是因为我很喜欢他们做的这只猫猫，所以希望它不只出现在原来的应用中，也能在使用 DeepSeek Harness 时更多地陪伴自己。BongoCat 是 DeskPet 的默认宠物，也是这个项目的起点。

感谢以下开源项目、宠物市场、素材社区以及所有宠物创作者。没有这些项目对格式、素材和社区生态的贡献，DeskPet 的宠物商店无法实现：

- [Awesome Codex Pet](https://github.com/legeling/awesome-codex-pet)
- [Codex Pets](https://codex-pets.net/)
- [PetDex](https://petdex.dev/)
- [SpriteYard](https://www.spriteyard.com/)
- [AgentBro Pet Market](https://www.agentbro.net/pets)
- [OpenPets](https://openpets.dev/gallery)
- [Codex Anime Pets](https://github.com/chenxin-dlut/codex-anime-pets)

特别感谢每位上传、绘制、维护和分享宠物的创作者。DeskPet 只提供技术兼容和本地加载能力，宠物素材的版权、许可和商标归原作者及相关权利人所有。
