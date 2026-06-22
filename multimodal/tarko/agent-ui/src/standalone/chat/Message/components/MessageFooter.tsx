import React from 'react';
import { useCopyToClipboard } from '@tarko/ui';
import { FiClock, FiCheck, FiCopy, FiZap, FiActivity } from 'react-icons/fi';
import { formatTimestamp } from '@/common/utils/formatters';
import { Message as MessageType, ChatCompletionContentPart } from '@/common/types';
import { Tooltip } from '@tarko/ui';

interface MessageFooterProps {
  message: MessageType;
  className?: string;
}

/**
 * MessageFooter Component
 * Displays timestamp, copy functionality, and TTFT information for messages
 */
export const MessageFooter: React.FC<MessageFooterProps> = ({ message, className = '' }) => {
  const { isCopied, copyToClipboard } = useCopyToClipboard();
  const showTTFT = message.role === 'assistant' && message.ttftMs !== undefined;

  const handleCopy = () => {
    const textToCopy =
      typeof message.content === 'string'
        ? message.content
        : (message.content as ChatCompletionContentPart[])
            .filter((part) => part.type === 'text')
            .map((part) => part.text)
            .join('\n');

    copyToClipboard(textToCopy);
  };

  // Helper function to format elapsed time for display (always in ms for precision)
  const formatElapsedTime = (ms: number): string => {
    return `${ms}ms`;
  };

  return (
    <div className={`mt-1 mb-2 ${className}`}>
      <div className="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400 px-2">
        <div className="flex items-center gap-3">
          {/* Timestamp */}
          <div className="flex items-center">
            <FiClock size={10} className="mr-1" />
            {formatTimestamp(message.timestamp)}
          </div>

          {/* TTFT & TTLT Display with icons and consistent styling */}
          {showTTFT && (
            <div className="flex items-center gap-2">
              {/* TTFT */}
              <Tooltip title="首 Token 时间 (TTFT) - 从请求开始到收到第一个 Token 的时间">
                <div className="flex items-center">
                  <FiZap size={10} className="mr-1 text-gray-500 dark:text-gray-400" />
                  <span className="text-gray-500 dark:text-gray-400">
                    {formatElapsedTime(message.ttftMs!)}
                  </span>
                </div>
              </Tooltip>

              {/* TTLT (if different from TTFT) */}
              {message.ttltMs && message.ttltMs !== message.ttftMs && (
                <Tooltip title="末 Token 时间 (TTLT) - 从请求开始到完成的总时间">
                  <div className="flex items-center">
                    <FiActivity size={10} className="mr-1 text-gray-500 dark:text-gray-400" />
                    <span className="text-gray-500 dark:text-gray-400">
                      {formatElapsedTime(message.ttltMs)}
                    </span>
                  </div>
                </Tooltip>
              )}
            </div>
          )}
        </div>

        {/* Copy functionality */}
        <button
          onClick={handleCopy}
          className="flex items-center text-gray-400 hover:text-accent-500 dark:hover:text-accent-400 transition-colors"
          title="复制消息"
        >
          {isCopied ? <FiCheck size={12} /> : <FiCopy size={12} />}
          <span className="ml-1">{isCopied ? 'Copied' : 'Copy'}</span>
        </button>
      </div>
    </div>
  );
};
