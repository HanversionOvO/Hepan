import { Document, DomUtils } from '@ohos/htmlparser2';
import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from './ApiClient';
import { Collection, CollectionCreator } from './models/CollectionModels';

const TAG = '[CollectionApi]: ';

export class CollectionApi {
  public static async getCollections(): Promise<Collection[]> {
    try {
      // 1. 请求 forum.php，携带参数 mod=collection
      const doc: Document = await ApiClient.getInstance().requestHtml('forum.php', {
        'mod': 'collection'
      });

      // 2. 查找 id="ct" 的节点
      const ct = DomUtils.getElementById('ct', doc);
      if (!ct) {
        LogUtil.warn(TAG, 'Cannot find div#ct');
        return [];
      }

      // 3. 查找列表容器 (class="clct_list cl")
      // 使用递归查找 (recurse=true)
      const listDiv = DomUtils.findOne((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('clct_list'));
      }, [ct], true);

      if (!listDiv) {
        LogUtil.warn(TAG, 'Cannot find .clct_list');
        return [];
      }

      // 4. 查找所有 class 为 "xld xlda cl" 的 div (每一个专辑项)
      // 注意：这里使用 listDiv.children 查找
      const itemDivs = DomUtils.findAll((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('xld'));
      }, listDiv.children);

      const collections: Collection[] = [];

      itemDivs.forEach((item) => {
        try {
          // --- 解析单个专辑 ---

          // 1. 获取 Title (递归查找 dt -> a)
          const dt = DomUtils.findOne((e) => e.tagName === 'dt', item.children);
          const titleA = DomUtils.findOne((e) => e.tagName === 'a', dt ? dt.children : [], true);
          const title = titleA ? DomUtils.textContent(titleA).trim() : '';

          // 2. 获取 Collection Nums (递归查找 dd.m -> strong)
          const ddM =
            DomUtils.findOne((e) => e.tagName === 'dd' && !!(e.attribs['class']?.includes('m')), item.children);
          const numStrong = DomUtils.findOne((e) => e.tagName === 'strong', ddM ? ddM.children : [], true);
          const collection_nums = numStrong ? parseInt(DomUtils.textContent(numStrong).trim()) : 0;

          // 3. 获取详细信息 (subscribe, comment, creator, update, desc)
          // [关键修改] 使用 findAll 递归查找所有 dd，然后筛选出非数字展示区的那个 dd
          const allDds = DomUtils.findAll((e) => e.tagName === 'dd', item.children);
          const infoDd = allDds.find((e) => {
            const cls = e.attribs['class'];
            // 排除掉 class 包含 'm' 或 'hm' 的 dd (那些是显示数字的)
            return !cls || (!cls.includes('m') && !cls.includes('hm'));
          });

          let subscribe = 0;
          let comment = 0;
          let description = '';
          let creator: CollectionCreator = { username: '', uid: 0 };
          let lastUpdate = '';

          if (infoDd) {
            // 查找 infoDd 下所有的 p 标签
            const pTags = DomUtils.findAll((e) => e.tagName === 'p', infoDd.children);

            pTags.forEach((p) => {
              const text = DomUtils.textContent(p).trim();
              const pClass = p.attribs['class'];

              if (pClass === 'xg1') {
                // 解析创建者和时间: <p class="xg1"><a>User</a> 创建, 最后更新 Time</p>
                const userA = DomUtils.findOne((e) => e.tagName === 'a', p.children);
                if (userA) {
                  creator.username = DomUtils.textContent(userA).trim();
                  const href = userA.attribs['href'] || '';
                  const uidMatch = href.match(/uid=(\d+)/);
                  if (uidMatch) {
                    creator.uid = parseInt(uidMatch[1]);
                  }
                }

                // 解析最后更新时间
                const timeMatch = text.match(/最后更新\s+(.+)$/);
                if (timeMatch) {
                  lastUpdate = timeMatch[1].trim();
                }

              } else if (text.includes('订阅') && text.includes('评论')) {
                // 解析统计数据: <p>订阅 17, 评论 0</p>
                const statsMatch = text.match(/订阅\s*(\d+)[^0-9]*评论\s*(\d+)/);
                if (statsMatch) {
                  subscribe = parseInt(statsMatch[1]);
                  comment = parseInt(statsMatch[2]);
                }
              } else if (!text.includes('最新主题')) {
                // 解析描述信息 (排除包含"最新主题"的p标签，且内容不为空)
                if (text) {
                  description = text;
                }
              }
            });
          }

          collections.push({
            title,
            collection_nums,
            subscribe,
            comment,
            creator,
            description,
            lastUpdate
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