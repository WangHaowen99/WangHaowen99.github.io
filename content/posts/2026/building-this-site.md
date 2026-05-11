---
title: "用 Hugo 搭建 GitHub Pages 个人博客"
date: 2026-05-11T16:00:00+08:00
draft: false
categories:
  - 技术
tags:
  - Hugo
  - GitHub Pages
  - Markdown
series:
  - 建站笔记
description: "记录这个博客的技术选择、内容组织和部署方式。"
toc: true
---

这个站点使用 Hugo 生成静态页面，通过 GitHub Actions 部署到 GitHub Pages。文章主要用 Markdown 编写，适合长期维护技术笔记、项目记录和生活观察。

## 为什么选择 Hugo

Hugo 的优势很直接：

- 构建速度快。
- Markdown 工作流简单。
- 可以完全控制模板和样式。
- 适合部署到 `*.github.io` 这类静态站点。

## 内容结构

当前站点保留这些主要栏目：

| 栏目 | 用途 |
| --- | --- |
| 文章 | 技术文章和长文记录 |
| 专栏 | 按主题聚合文章 |
| 项目 | 项目说明、工具和实验 |
| 生活 | 非技术类记录 |
| About | 个人介绍和链接 |

## 写作方式

新文章可以放在 `content/posts/YYYY/` 下，例如：

```text
content/posts/2026/example-post.md
```

每篇文章使用 front matter 描述标题、日期、分类、标签和专栏：

```yaml
---
title: "文章标题"
date: 2026-05-11T16:00:00+08:00
categories:
  - 技术
tags:
  - Markdown
series:
  - 建站笔记
toc: true
---
```

## 部署方式

代码推送到 `main` 分支后，GitHub Actions 会运行：

```bash
hugo --minify --baseURL "${{ steps.pages.outputs.base_url }}/"
```

构建结果发布到 GitHub Pages，最终访问地址是：

```text
https://WangHaowen99.github.io
```

## 下一步

后续可以继续补充真实文章、项目说明、个人介绍和 Giscus 评论配置。
