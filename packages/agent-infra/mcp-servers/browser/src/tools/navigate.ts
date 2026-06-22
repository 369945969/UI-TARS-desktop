import { z } from 'zod';
import { TimeoutError } from 'puppeteer-core';
import { removeHighlights } from '@agent-infra/browser-use';
import { defineTool } from './defineTool.js';

const navigateTool = defineTool({
  name: 'browser_navigate',
  config: {
    description: 'Navigate to a URL',
    inputSchema: {
      url: z.string(),
    },
  },
  handle: async (ctx, args) => {
    const { page, logger, buildDomTree } = ctx;
    const MAX_RETRIES = 2;
    const NAV_TIMEOUT = 60000; // 60 seconds

    let lastError: unknown = null;

    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        await page.goto(args.url, { timeout: NAV_TIMEOUT, waitUntil: ['domcontentloaded'] });

        logger.info(`navigateTo complete (attempt ${attempt})`);
        const { clickableElements } = (await buildDomTree(page)) || {};
        logger.info('clickableElements', clickableElements);
        await removeHighlights(page);

        return {
          content: [
            {
              type: 'text',
              text:
                `Navigated to ${args.url}` +
                (clickableElements
                  ? `\nclickable elements(Might be outdated, if an error occurs with the index element, use \`browser_get_clickable_elements\` to refresh it): \n${clickableElements}`
                  : 'No clickable elements found'),
            },
          ],
          isError: false,
        };
      } catch (error: unknown) {
        lastError = error;
        logger.warn(`Navigation attempt ${attempt} failed:`, error);

        if (attempt < MAX_RETRIES) {
          logger.info(`Retrying navigation (attempt ${attempt + 1})...`);
          await new Promise((r) => setTimeout(r, 2000));
        }
      }
    }

    // All retries failed - check if it's a timeout (page might still be usable)
    if (
      lastError instanceof TimeoutError ||
      (lastError as Error)?.message?.includes('timeout')
    ) {
      logger.warn(
        'Navigation timeout after retries, but page might still be usable:',
        lastError,
      );
      return {
        content: [
          {
            type: 'text',
            text: 'Navigation timeout after retries, but page might still be usable:',
          },
        ],
        isError: false,
      };
    } else {
      logger.error('NavigationTo failed after retries:', lastError);
      return {
          content: [
            {
              type: 'text',
              text: `Navigation failed ${error instanceof Error ? error?.message : error}`,
            },
          ],
          isError: true,
        };
      }
    }
  },
});

const goBackTool = defineTool({
  name: 'browser_go_back',
  config: {
    description: 'Go back to the previous page',
  },
  handle: async (ctx, args) => {
    const { page, logger } = ctx;

    try {
      await page.goBack();
      logger.info('Navigation back completed');
      return {
        content: [{ type: 'text', text: 'Navigated back' }],
        isError: false,
      };
    } catch (error) {
      if (error instanceof Error && error.message.includes('timeout')) {
        logger.warn(
          'Back navigation timeout, but page might still be usable:',
          error,
        );
        return {
          content: [
            {
              type: 'text',
              text: 'Back navigation timeout, but page might still be usable:',
            },
          ],
          isError: false,
        };
      } else {
        logger.error('Could not navigate back:', error);
        return {
          content: [
            {
              type: 'text',
              text: 'Could not navigate back',
            },
          ],
          isError: true,
        };
      }
    }
  },
});

const goForwardTool = defineTool({
  name: 'browser_go_forward',
  config: {
    description: 'Go forward to the next page',
  },
  handle: async (ctx, args) => {
    const { page, logger } = ctx;

    try {
      await page.goForward();
      logger.info('Navigation back completed');
      return {
        content: [{ type: 'text', text: 'Navigated forward' }],
        isError: false,
      };
    } catch (error) {
      if (error instanceof Error && error.message.includes('timeout')) {
        logger.warn(
          'forward navigation timeout, but page might still be usable:',
          error,
        );
        return {
          content: [
            {
              type: 'text',
              text: 'forward navigation timeout, but page might still be usable:',
            },
          ],
          isError: false,
        };
      } else {
        logger.error('Could not navigate forward:', error);
        return {
          content: [
            {
              type: 'text',
              text: 'Could not navigate forward',
            },
          ],
          isError: true,
        };
      }
    }
  },
});

export default [navigateTool, goBackTool, goForwardTool];
