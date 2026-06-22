/*
 * Copyright (c) 2025 Bytedance, Inc. and its affiliates.
 * SPDX-License-Identifier: Apache-2.0
 */

import type { BaseAgentWebUIImplementation } from '@tarko/interface';

const sandboxBaseUrl = location.host.includes('localhost') ? 'http://localhost:8080' : '';

/**
 * Default Agent UI Configuration for standalone deployment
 */
export const DEFAULT_WEBUI_CONFIG: BaseAgentWebUIImplementation = {
  logo: 'https://lf3-static.bytednsdoc.com/obj/eden-cn/zyha-aulnh/ljhwZthlaukjlkulzlp/icon.png',
  title: 'Tarko Agent UI',
  subtitle: '与丰富的真实工具无缝集成',
  welcomTitle: '一个多模态 AI 智能体',
  welcomePrompts: [
    '搜索最新的 GUI Agent 论文',
    '查找 UI TARS 的相关信息',
    '告诉我今天 ProductHunt 上最受欢迎的 5 个项目',
    '用 Python 写一个 hello world',
  ],
  workspace: {
    navItems: [
      {
        title: '代码服务器',
        link: sandboxBaseUrl + '/code-server/',
        icon: 'code',
      },
      {
        title: 'VNC',
        link: sandboxBaseUrl + '/vnc/index.html?autoconnect=true',
        icon: 'monitor',
      },
    ],
  },
  guiAgent: {
    defaultScreenshotRenderStrategy: 'afterAction',
    enableScreenshotRenderStrategySwitch: true,
    renderGUIAction: true,
    renderBrowserShell: false,
  },
  layout: {
    enableLayoutSwitchButton: true,
  },
};
