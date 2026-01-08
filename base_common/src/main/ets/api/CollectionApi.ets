import { Document, DomUtils } from '@ohos/htmlparser2';
import { LogUtil } from '@pura/harmony-utils';
import { Element } from 'domhandler';
import { ApiClient } from './ApiClient';
import { Collection, CollectionSortOrder, CollectionUser } from './models/CollectionModels';

const TAG = '[CollectionApi]: ';

export class CollectionApi {
  /**
   * 获取淘专辑列表
   * @param page 页码，默认为 1
   * @param order 排序方式，默认为按创建时间 (CollectionSortOrder.DATE)
   */
  public static async getCollections(page: number = 1,
    order: CollectionSortOrder = CollectionSortOrder.DATE): Promise<Collection[]> {
    try {
      // 1. 构造请求参数
      const params: Record<string, string | number> = {
        'mod': 'collection',
        'op': 'all',
        'page': page
      };

      // 只有当 order 不为空时（即不是默认的按时间排序），才添加 order 参数
      if (order !== CollectionSortOrder.DATE) {
        params['order'] = order;
      }

      // 2. 请求 forum.php
      const doc: Document = await ApiClient.getInstance().requestHtml('forum.php', params);

      // 3. 查找 id="ct" 的节点
      const ct = DomUtils.getElementById('ct', doc);
      if (!ct) {
        LogUtil.warn(TAG, 'Cannot find div#ct');
        return [];
      }

      // 4. 查找列表容器 (class="clct_list cl")
      const listDiv = DomUtils.findOne((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('clct_list'));
      }, [ct], true);

      if (!listDiv) {
        LogUtil.warn(TAG, 'Cannot find .clct_list');
        return [];
      }

      // 5. 查找所有 class 为 "xld xlda cl" 的 div (每一个专辑项)
      const itemDivs = DomUtils.findAll((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('xld'));
      }, listDiv.children);

      const collections: Collection[] = [];

      itemDivs.forEach((item) => {
        try {
          // --- 解析单个专辑 (逻辑保持不变) ---

          // 1. 获取 Title
          const dt = DomUtils.findOne((e) => e.tagName === 'dt', item.children);
          const titleA = DomUtils.findOne((e) => e.tagName === 'a', dt ? dt.children : [], true);

          let title = '';
          let ctid = 0;

          if (titleA) {
            title = DomUtils.textContent(titleA).trim();
            const href = titleA.attribs['href'] || '';
            const ctidMatch = href.match(/ctid=(\d+)/);
            if (ctidMatch) {
              ctid = parseInt(ctidMatch[1]);
            }
          }

          let tags: string[] = [];
          if (dt) {
            const tagSpan = DomUtils.findOne((e) => {
              return !!(e.attribs && e.attribs['class'] && e.attribs['class'].includes('ctag_keyword'));
            }, dt.children, true); // 递归查找，因为 span 可能在 div 内

            if (tagSpan) {
              const tagAs = DomUtils.findAll((e) => e.tagName === 'a', tagSpan.children);
              tagAs.forEach(a => {
                const t = DomUtils.textContent(a).trim();
                if (t) {
                  tags.push(t);
                }
              });
            }
          }

          // 2. 获取 Collection Nums
          const ddM =
            DomUtils.findOne((e) => e.tagName === 'dd' && !!(e.attribs['class']?.includes('m')), item.children);
          const numStrong = DomUtils.findOne((e) => e.tagName === 'strong', ddM ? ddM.children : [], true);
          const collection_nums = numStrong ? parseInt(DomUtils.textContent(numStrong).trim()) : 0;

          // 3. 获取详细信息
          const allDds = DomUtils.findAll((e) => e.tagName === 'dd', item.children);
          const infoDd = allDds.find((e) => {
            const cls = e.attribs['class'];
            return !cls || (!cls.includes('m') && !cls.includes('hm'));
          });

          let subscribe = 0;
          let comment = 0;
          let description = '';
          let creator: CollectionUser = { username: '', uid: 0 };
          let lastUpdate = '';

          if (infoDd) {
            const infoElement = infoDd as Element;
            const pTags = DomUtils.findAll((e) => e.tagName === 'p', infoElement.children);

            pTags.forEach((p) => {
              const text = DomUtils.textContent(p).trim();
              const pClass = p.attribs['class'];

              if (pClass === 'xg1') {
                const userA = DomUtils.findOne((e) => e.tagName === 'a', p.children);
                if (userA) {
                  creator.username = DomUtils.textContent(userA).trim();
                  const href = userA.attribs['href'] || '';
                  const uidMatch = href.match(/uid=(\d+)/);
                  if (uidMatch) {
                    creator.uid = parseInt(uidMatch[1]);
                  }
                }
                const timeMatch = text.match(/最后更新\s+(.+)$/);
                if (timeMatch) {
                  lastUpdate = timeMatch[1].trim();
                }
              } else if (text.includes('订阅') && text.includes('评论')) {
                const statsMatch = text.match(/订阅\s*(\d+)[^0-9]*评论\s*(\d+)/);
                if (statsMatch) {
                  subscribe = parseInt(statsMatch[1]);
                  comment = parseInt(statsMatch[2]);
                }
              } else if (!text.includes('最新主题')) {
                if (text) {
                  description = text;
                }
              }
            });
          }

          collections.push({
            ctid,
            title,
            collection_nums,
            subscribe,
            comment,
            creator,
            description,
            lastUpdate,
            tags
          });

        } catch (e) {
          LogUtil.error(TAG, 'Parse item error', JSON.stringify(e));
        }
      });

      return collections;

    } catch (error) {
      LogUtil.error(TAG, 'getCollections failed', JSON.stringify(error));
      throw new Error(error);
    }
  }
}