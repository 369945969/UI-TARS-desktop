/*
 * Copyright (c) 2025 Bytedance, Inc. and its affiliates.
 * SPDX-License-Identifier: Apache-2.0
 */

import { AgentWebUIImplementation } from '@agent-tars/interface';

/**
 * Default Agent UI Configuration for Agent TARS
 */
export const AGENT_TARS_WEBUI_CONFIG: AgentWebUIImplementation = {
  logo: 'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/appicon.png',
  title: 'Agent TARS',
  subtitle: '与丰富的真实工具无缝集成',
  welcomTitle: '一个多模态 AI 智能体',
  welcomePrompts: [],
  welcomeCards: [
    {
      title: '搜索最新的 GUI Agent 论文',
      category: '研究',
      prompt: '搜索最新的 GUI Agent 论文',
      image:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop&crop=center',
    },
    {
      title: '查找 UI TARS 的相关信息',
      category: '研究',
      prompt: '查找 UI TARS 的相关信息',
      image:
        'https://images.unsplash.com/photo-1518186285589-2f7649de83e0?w=400&h=300&fit=crop&crop=center',
    },
    {
      title: '告诉我今天 ProductHunt 上最受欢迎的 5 个项目',
      category: '研究',
      prompt: '告诉我今天 ProductHunt 上最受欢迎的 5 个项目',
      image:
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop&crop=center',
    },
    {
      title: '请帮我预订 10 月 1 日杭州到深圳最早的航班',
      category: 'AI 浏览器',
      prompt:
        '请帮我预订 10 月 1 日杭州到深圳最早的航班。注意：不要使用携程(ctrip)，改用其他订票网站如去哪儿、飞猪或同程',
      image:
        'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&h=300&fit=crop&crop=center',
    },
    {
      title: '分析 Google 网络请求',
      category: '代码执行',
      prompt: '使用命令帮我分析 google.com 的网络请求',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/analyze-google-network-request-ea86c5.jpg',
    },
    {
      title: '使用远程 Agent API 分支',
      category: '代码执行',
      prompt: '直接使用远程的 feat/agent-respnse-api 分支',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/featagent-respnse-api-3e7e29.jpg',
    },
    {
      title: '调研 Claude Code 和 Gemini 的 CLI 参数',
      category: '研究',
      prompt:
        '帮我调研一下，claude code 和 gemini 使用 cli 直接运行，输入 prompt 的 cli 参数是什么？',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/claude-code-gemini-cli-d3fbf7.jpg',
    },
    {
      title: '查询网站工信部备案',
      category: 'AI 浏览器',
      prompt:
        '帮我打开 https://beian.miit.gov.cn/#/Integrated/recordQuery 查看以下网站的备案\r\n\r\n- https://www.bytedance.com\r\n- https://www.douyin.com\r\n- http://toutiao.com/\r\n\r\n整理成表格发给我，注意每次切换 website 要清空输入框',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/httpsbeianmiitgovcnintegratedrecordquery-httpswwwbytedancec-120388.jpg',
    },
    {
      title: '绘制杭州天气图表',
      category: 'MCP',
      prompt: '帮我画一张杭州一个月的天气图表',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/draw-me-a-chart-34bc8d.jpg',
    },
    {
      title: '如何修复 Git 进程错误',
      category: '代码执行',
      prompt:
        "如何修复这个报错：Another git process seems to be running in this repository, e.g.\r\nan editor opened by 'git commit'. Please make sure all processes\r\nare terminated then try again. If it still fails, a git process\r\nmay have crashed in this repository earlier:\r\nremove the file manually to continue.\r\nerror: Unable to create '/Users/chenhaoli/workspace/code/UI-TARS-desktop/.git/logs/refs/remotes/origin/release/v0.2.0-beta.1.lock': File exists.",
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/another-git-process-seems-b6495e.jpg',
    },
    {
      title: '深度调研字节跳动 Web Infra',
      category: '研究',
      prompt:
        '帮我深度调研一下 ByteDance Web Infra，给出一份详细的调研报告\r\n\r\n我期待覆盖的信息： \r\n\r\n1. 团队介绍\r\n2. 主要的开源项目、贡献者；\r\n3. 应用场景； \r\n4. 项目活跃状态；\r\n5. 社区影响力；\r\n6. 技术蓝图；\r\n7. 你的思考；\r\n\r\n要求报告采用 Markdown 输出中文，最后写入文件，同时，并使用 HTML 绘制一个图文并茂的 Slide，介绍 ByteDance Web Infra',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/bytedance-web-infra-1-002133.jpg',
    },
    {
      title: '重现 Agent TARS 展示界面',
      category: 'AI 编程',
      prompt: '编写代码完全重现这个界面',
      image:
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop&crop=center',
    },
    {
      title: '为 Agent TARS 设计新粗野主义海报',
      category: 'AI 编程',
      prompt:
        '设计一款符合 neo-brutalism 设计风格的海报\r\n\r\n- 主题：Agent TARS\r\n- 标语：开源多模态 AI Agent\r\n- 图标：https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/icon.png\r\n- 醒目的 CTA：https://agent-tars.com',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/neo-brutalism-poster-agent-bfa30c.jpg',
    },
    {
      title: '用 Python 理论解决问题',
      category: '代码执行',
      prompt: '尝试用理论结合 Python 命令来解决这个问题。注意 "I" 和 "H" 节点没有连接。',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/solve-problem-theory-python-020cc2.jpg',
    },
    {
      title: '在 Priceline 预订机票',
      category: 'AI 浏览器',
      prompt:
        '请帮我在 Priceline 上预订 9 月 1 日从圣何塞到纽约的最早航班，以及 9 月 6 日的最晚返程航班\r\n\r\n提示：切换到排序后，不需要再点击搜索。请用中文回复我',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/book-flights-san-jose-3c5d03.jpg',
    },
    {
      title: '打开、游玩并通关游戏',
      category: 'AI 浏览器',
      prompt:
        '1. 打开这个游戏：https://cpstest.click/en/aim-trainer#google_vignette\r\n2. 选择总时长为 50 秒\r\n3. 玩并通关这个游戏',
      image:
        'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/storage/general/aim-trainer-50-seconds-e2416d.jpg',
    },
  ],
  enableContextualSelector: false,
  guiAgent: {
    defaultScreenshotRenderStrategy: 'beforeAction',
    enableScreenshotRenderStrategySwitch: true,
    renderGUIAction: true,
  },
  layout: {
    defaultLayout: 'narrow-chat',
    enableLayoutSwitchButton: true,
  },
  debug: {
    enableEventStreamViewer: true,
  },
};
