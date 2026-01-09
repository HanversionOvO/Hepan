import { Document, DomUtils } from '@ohos/htmlparser2';
import { LogUtil } from '@pura/harmony-utils';
import { Element } from 'domhandler';
import { ApiClient } from './ApiClient';
import { ForumApi } from './ForumApi';
import {
  Collection,
  CollectionDetail,
  CollectionFollowResult,
  CollectionSortOrder,
  CollectionUser
} from './models/CollectionModels';

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
          // --- 解析单个专辑 ---

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
            }, dt.children, true);

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
          // 变动点：直接实例化 CollectionUser
          let creator = new CollectionUser();
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

          // 变动点：使用 new Collection() 并赋值
          // 如果你的 Collection 构造函数支持传入对象 (constructor(data?: any))，也可以直接 new Collection({...})
          const collection = new Collection();
          collection.ctid = ctid;
          collection.title = title;
          collection.collection_nums = collection_nums;
          collection.subscribe = subscribe;
          collection.comment = comment;
          collection.creator = creator; // 这里的 creator 已经是类实例
          collection.description = description;
          collection.lastUpdate = lastUpdate;
          collection.tags = tags;

          collections.push(collection);

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

  public static async getCollectionDetail(ctid: number, page: number = 1): Promise<CollectionDetail> {
    try {
      // 1. 请求页面
      const params: Record<string, string | number> = {
        'mod': 'collection',
        'action': 'view',
        'ctid': ctid,
        'page': page
      };
      const doc: Document = await ApiClient.getInstance().requestHtml('forum.php', params);

      // 变动点：实例化 CollectionDetail
      const detail = new CollectionDetail();
      detail.ctid = ctid;
      detail.ties = [];
      detail.isFollow = false;
      detail.formhash = '';

      const scripts = DomUtils.getElementsByTagName('script', doc.children);
      for (const script of scripts) {
        const text = DomUtils.textContent(script);
        if (!text) {
          continue;
        }

        if (text.includes('var followstatus')) {
          const match = text.match(/var\s+followstatus\s*=\s*(\d+);/);
          if (match) {
            const status = parseInt(match[1]);
            detail.isFollow = status === 1;
          }
        }

        if (text.includes('function followcollectionurl()')) {
          const hashMatch = text.match(/formhash=([a-zA-Z0-9]+)/);
          if (hashMatch) {
            detail.formhash = hashMatch[1];
          }
        }
      }

      const rateStarSpan = DomUtils.findOne((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('clct_ratestar'));
      }, doc.children, true);

      if (rateStarSpan) {
        const starElem = DomUtils.findOne((elem) => {
          return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('star'));
        }, rateStarSpan.children);
        if (starElem) {
          const classStr = starElem.attribs['class'] || '';
          const match = classStr.match(/star(\d+)/);
          if (match) {
            detail.rate = parseInt(match[1]);
          }
        }
      }

      // 3. 解析最新订阅用户 (newSubsUser)
      const bmDivs = DomUtils.findAll((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('bm'));
      }, doc.children);

      const subBm = bmDivs.find(bm => {
        const h2 = DomUtils.findOne(e => e.tagName === 'h2', bm.children, true);
        return h2 && DomUtils.textContent(h2).includes('最新订阅');
      });

      if (subBm) {
        const ul = DomUtils.findOne(e => e.tagName === 'ul', subBm.children, true);
        if (ul) {
          const lis = DomUtils.findAll(e => e.tagName === 'li', ul.children);
          const users: CollectionUser[] = [];
          lis.forEach(li => {
            const p = DomUtils.findOne(e => e.tagName === 'p', li.children);
            if (p) {
              const a = DomUtils.findOne(e => e.tagName === 'a', p.children);
              if (a) {
                const username = DomUtils.textContent(a).trim();
                const href = a.attribs['href'] || '';
                const uidMatch = href.match(/uid=(\d+)/);
                if (username && uidMatch) {
                  // 变动点：实例化 CollectionUser
                  const u = new CollectionUser();
                  u.username = username;
                  u.uid = parseInt(uidMatch[1]);
                  users.push(u);
                }
              }
            }
          });
          detail.newSubsUser = users;
        }
      }

      // 4. 解析用户更多淘专辑 (userMoreCollections)
      const moreBm = bmDivs.find(bm => {
        const h2 = DomUtils.findOne(e => e.tagName === 'h2', bm.children, true);
        return h2 && DomUtils.textContent(h2).includes('他还有这些淘帖');
      });

      // 获取当前专辑的创建者信息
      let currentCreator = new CollectionUser(); // 变动点：实例化
      const pTags = DomUtils.findAll(e => e.tagName === 'p', doc.children);
      const creatorP = pTags.find(p => DomUtils.textContent(p).includes('专辑创建人'));
      if (creatorP) {
        const aTag = DomUtils.findOne(e => e.tagName === 'a', creatorP.children);
        if (aTag) {
          currentCreator.username = DomUtils.textContent(aTag).trim();
          const href = aTag.attribs['href'] || '';
          const uidMatch = href.match(/uid=(\d+)/);
          if (uidMatch) {
            currentCreator.uid = parseInt(uidMatch[1]);
          }
        }
      }

      if (moreBm) {
        const bmC =
          DomUtils.findOne(e => !!(e.attribs['class'] && e.attribs['class'].includes('bm_c')), moreBm.children);
        if (bmC) {
          const moreCols: Collection[] = [];
          const children = bmC.children.filter(c => c.type === 'tag');
          // 两个一组：pbn 是标题链接，pbm 是统计数据
          for (let i = 0; i < children.length - 1; i += 2) {
            const nodeTitle = children[i] as Element;
            const nodeInfo = children[i + 1];

            const a = DomUtils.findOne(e => e.tagName === 'a', nodeTitle.children);
            if (a) {
              const colTitle = DomUtils.textContent(a).trim();
              const colHref = a.attribs['href'] || '';
              const colCtidMatch = colHref.match(/ctid=(\d+)/);
              const colCtid = colCtidMatch ? parseInt(colCtidMatch[1]) : 0;

              const infoText = DomUtils.textContent(nodeInfo);
              const infoMatch = infoText.match(/主题\s*(\d+).*订阅\s*(\d+).*评论\s*(\d+)/);

              if (colCtid) {
                // 变动点：实例化 Collection
                const col = new Collection();
                col.ctid = colCtid;
                col.title = colTitle;
                col.collection_nums = infoMatch ? parseInt(infoMatch[1]) : 0;
                col.subscribe = infoMatch ? parseInt(infoMatch[2]) : 0;
                col.comment = infoMatch ? parseInt(infoMatch[3]) : 0;
                col.creator = currentCreator; // 传入类实例
                moreCols.push(col);
              }
            }
          }
          detail.userMoreCollections = moreCols;
        }
      }

      // 5. 解析帖子列表 (ties)
      const tlBm = DomUtils.findOne(e => {
        return !!(e.attribs && e.attribs['class'] && e.attribs['class'].includes('tl') &&
        e.attribs['class'].includes('bm'));
      }, doc.children, true);

      const tids: number[] = [];
      if (tlBm) {
        const threadLinks = DomUtils.findAll((e) => {
          return e.tagName === 'a' && !!(e.attribs['class'] && e.attribs['class'].includes('xst'));
        }, tlBm.children);

        threadLinks.forEach((a) => {
          const href = a.attribs['href'] || '';
          const tidMatch = href.match(/tid=(\d+)/);
          if (tidMatch) {
            tids.push(parseInt(tidMatch[1]));
          }
        });
      }

      // 并发获取所有帖子的详情
      if (tids.length > 0) {
        const tiePromises = tids.map(tid => ForumApi.getForumDetailOld(tid, 0, 0, 1, 1));
        const ties = await Promise.all(tiePromises);
        detail.ties = ties;
      }

      return detail;

    } catch (error) {
      LogUtil.error(TAG, 'getCollectionDetail failed', JSON.stringify(error));
      // 变动点：返回空对象实例
      const empty = new CollectionDetail();
      empty.ctid = ctid;
      return empty;
    }
  }

  // toggleFollow 方法通常只返回操作结果，不涉及 UI 观察，保持原样即可，或者确保返回值类型兼容
  public static async toggleFollow(ctid: number, isFollow: boolean, formhash: string): Promise<CollectionFollowResult> {
    // ... (代码保持不变，只需确保 CollectionFollowResult 引用正确)
    try {
      const op = isFollow ? 'unfo' : 'follow';
      const params: Record<string, string | number> = {
        'mod': 'collection',
        'action': 'follow',
        'op': op,
        'ctid': ctid,
        'formhash': formhash,
        'inajax': '1'
      };

      const doc = await ApiClient.getInstance().requestHtml('forum.php', params);

      const xml = DomUtils.getOuterHTML(doc);

      if (xml.includes('alert_info')) {
        const match = xml.match(/class="alert_info">(.+?)<script/);
        const msg = match ? match[1].trim() : '操作成功';
        return { success: true, message: msg };
      } else if (xml.includes('alert_error')) {
        const match = xml.match(/class="alert_error">(.+?)<script/);
        const msg = match ? match[1].trim() : '操作失败';
        return { success: false, message: msg };
      }

      return { success: false, message: '请求异常' };

    } catch (e) {
      LogUtil.error(TAG, 'toggleFollow failed', JSON.stringify(e));
      return { success: false, message: '网络错误' };
    }
  }
}