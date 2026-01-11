import { Document, DomUtils } from '@ohos/htmlparser2';
import { ApiClient } from './ApiClient';
import { WaterMission, WaterMissionState, WaterModels, WaterRecord, WaterShopItem } from './models/WaterModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[WaterApi]: ';

export class WaterApi {
  /**
   * 获取水滴概况及记录
   * 1. 访问 op=base 获取当前水滴数
   * 2. 访问 op=log 获取水滴变更记录
   */
  public static async getWaterSummary(page: number = 1): Promise<WaterModels> {
    const waterModel = new WaterModels();

    // 并发执行两个请求以提高速度，或者按顺序执行。此处为了逻辑清晰按顺序执行。
    try {
      // --- 步骤 1: 获取当前水滴数量 (GET) ---
      // 页面: home.php?mod=spacecp&ac=credit&op=base
      const baseParams: Record<string, string | number> = {
        'mod': 'spacecp',
        'ac': 'credit',
        'op': 'base'
      };

      const baseDoc: Document = await ApiClient.getInstance().requestHtml('home.php', baseParams);

      // 解析 page1.html 结构: <li class="xi1 cl"><em>水滴: </em>47 滴 &nbsp;</li>
      // 查找包含 class="xi1" 的 li 元素
      const xi1Li = DomUtils.findOne((elem) => {
        return elem.tagName === 'li' &&
          !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('xi1'));
      }, baseDoc.children, true);

      if (xi1Li) {
        const text = DomUtils.textContent(xi1Li).trim();
        // 文本内容大概为 "水滴: 47 滴"，使用正则提取数字
        const match = text.match(/(\d+)/);
        if (match) {
          waterModel.water_nums = parseInt(match[1]);
        }
      }

      // --- 步骤 2: 获取水滴记录 (POST) ---
      // 页面: home.php?mod=spacecp&ac=credit&op=log
      // 表单参数: exttype=2, income=0, search=true, op=log, ac=credit, mod=spacecp
      const logParams: Record<string, string | number | boolean> = {
        'mod': 'spacecp',
        'ac': 'credit',
        'op': 'log',
        'exttype': 2,
        'page': page
      };

      const logDoc: Document = await ApiClient.getInstance().requestHtml(
        'home.php',
        logParams,
        http.RequestMethod.GET
      );

      // 解析 page2.html 结构: <table class="dt">...</table>
      // 查找所有 class 为 dt 的 table
      const dtTable = DomUtils.findOne((elem) => {
        return elem.tagName === 'table' &&
          !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('dt'));
      }, logDoc.children, true);

      if (dtTable) {
        // 获取所有行 tr
        const trs = DomUtils.findAll((elem) => elem.tagName === 'tr', dtTable.children);

        const records: WaterRecord[] = [];

        // 遍历行，跳过表头 (通常表头是 th, 内容是 td)
        trs.forEach((tr) => {
          const tds = DomUtils.findAll((elem) => elem.tagName === 'td', tr.children);

          // 确保这一行有足够的列 (page2.html 中有 4 列: 操作, 积分变更, 详情, 变更时间)
          if (tds.length >= 4) {
            const record = new WaterRecord();

            // 1. 操作描述 (第1列)
            record.modify_desc = DomUtils.textContent(tds[0]).trim();

            // 2. 积分变更 (第2列) - 格式如: "水滴 +10"
            const changeText = DomUtils.textContent(tds[1]).trim();
            const numMatch = changeText.match(/(\d+)/);
            if (numMatch) {
              record.modify_water = parseInt(numMatch[1]);
            }
            // 判断增减: 包含 '+' 为增加(0)，否则视为减少(1) (根据通常逻辑及提供的html示例)
            if (changeText.includes('+')) {
              record.modify_state = 0;
            } else {
              record.modify_state = 1;
            }

            // 3. 操作详情 (第3列)
            record.modyfy_info = DomUtils.textContent(tds[2]).trim();

            // 4. 操作时间 (第4列)
            record.modify_time = DomUtils.textContent(tds[3]).trim();

            records.push(record);
          }
        });

        waterModel.records = records;
      }

    } catch (e) {
      LogUtil.error(TAG, 'getWaterSummary failed', JSON.stringify(e));
      // 发生错误时，尽量返回已获取的部分数据或空对象，防止崩溃
    }

    return waterModel;
  }

  /**
   * 获取水滴任务列表
   * @param state 任务状态 (new | doing | done | failed)
   */
  public static async getWaterMission(state: WaterMissionState): Promise<WaterMission[]> {
    const missions: WaterMission[] = [];
    const baseUrl = ApiClient.getInstance().baseUrl; // 可以从 ApiClient 获取，这里也可以直接硬编码或提取

    try {
      // 1. 构造请求参数
      // 链接: home.php?mod=task&item={state}
      const params: Record<string, string> = {
        'mod': 'task',
        'item': state
      };

      // 2. 请求 HTML
      const doc: Document = await ApiClient.getInstance().requestHtml('home.php', params);

      // 3. 解析 DOM
      // 查找包含任务列表的 div (class="ptm")
      const ptmDiv = DomUtils.findOne((elem) => {
        return !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('ptm'));
      }, doc.children, true);

      if (!ptmDiv) {
        // 如果找不到 ptm div，可能是没有任务或者结构变化
        return missions;
      }

      // 查找表格
      const table = DomUtils.findOne((elem) => elem.tagName === 'table', ptmDiv.children);
      if (!table) {
        return missions;
      }

      // 获取所有行
      const trs = DomUtils.findAll((elem) => elem.tagName === 'tr', table.children);

      trs.forEach((tr) => {
        const tds = DomUtils.findAll((elem) => elem.tagName === 'td', tr.children);
        // 通常一行有 4 列：图片 | 描述 | 奖励 | 操作
        if (tds.length >= 4) {
          const mission = new WaterMission();
          mission.mission_state = state;

          // --- 1. 图标 (td[0]) ---
          const img = DomUtils.findOne((elem) => elem.tagName === 'img', tds[0].children);
          if (img && img.attribs && img.attribs['src']) {
            let src = img.attribs['src'];
            if (!src.startsWith('http')) {
              src = baseUrl + '/' + src;
            }
            mission.mission_icon = src;
          }

          // --- 2. 任务信息 (td[1]) ---
          // 名称和人气在 h3 中
          const h3 = DomUtils.findOne((elem) => elem.tagName === 'h3', tds[1].children);
          if (h3) {
            // 名称
            const nameA = DomUtils.findOne((elem) => elem.tagName === 'a', h3.children);
            if (nameA) {
              mission.mission_name = DomUtils.textContent(nameA).trim();
            }
            // 人气
            const hotText = DomUtils.textContent(h3); // 例如 "(人气: 25283)"
            const hotMatch = hotText.match(/人气:\s*(\d+)/);
            if (hotMatch) {
              mission.mission_hot = parseInt(hotMatch[1]);
            } else {
              // 备用：尝试从 span 或 a 标签中获取
              const hotA = DomUtils.findOne((elem) => elem.tagName === 'a' &&
                (!elem.attribs['href'] || elem.attribs['href'].includes('#parter')), h3.children);
              if (hotA) {
                const hotNum = parseInt(DomUtils.textContent(hotA).trim());
                if (!isNaN(hotNum)) {
                  mission.mission_hot = hotNum;
                }
              }
            }
          }

          // 描述
          const pDesc = DomUtils.findOne((elem) => elem.tagName === 'p' &&
            !!(elem.attribs['class'] && elem.attribs['class'].includes('xg2')), tds[1].children);
          if (pDesc) {
            mission.mission_desc = DomUtils.textContent(pDesc).trim();
          }

          // 进度 (仅进行中任务)
          if (state === WaterMissionState.DOING) {
            // <div class="pbg ..."> ... <div class="xs0"> 已完成 ... % </div> </div>
            const pbgDiv = DomUtils.findOne((elem) => !!(elem.attribs && elem.attribs['class'] &&
            elem.attribs['class'].includes('pbg')), tds[1].children);
            if (pbgDiv) {
              const xs0Div = DomUtils.findOne((elem) => !!(elem.attribs && elem.attribs['class'] &&
              elem.attribs['class'].includes('xs0')), pbgDiv.children);
              if (xs0Div) {
                const progressText = DomUtils.textContent(xs0Div).trim(); // "已完成 0 %"
                const progressMatch = progressText.match(/(\d+)/);
                if (progressMatch) {
                  mission.mission_progress = parseInt(progressMatch[1]);
                }
              }
            }
          }

          // --- 3. 奖励 (td[2]) ---
          // 例如 "积分 水滴 30 滴"
          const rewardText = DomUtils.textContent(tds[2]).trim();
          const splitIndex = rewardText.indexOf(' ');
          if (splitIndex > 0) {
            mission.mission_reward = rewardText.substring(0, splitIndex).trim();
            mission.mission_reward_value = rewardText.substring(splitIndex).trim();
          } else {
            mission.mission_reward = rewardText; // Fallback
          }

          // --- 4. 操作链接 (td[3]) ---
          const actionA = DomUtils.findOne((elem) => elem.tagName === 'a', tds[3].children);
          if (actionA && actionA.attribs && actionA.attribs['href']) {
            let href = actionA.attribs['href'];
            // 处理相对链接
            if (!href.startsWith('http')) {
              href = baseUrl + '/' + href;
            }
            mission.mission_href = href;
          }

          missions.push(mission);
        }
      });

    } catch (e) {
      LogUtil.error(TAG, 'getWaterMission failed', JSON.stringify(e));
    }

    return missions;
  }

  /**
   * 获取道具商店列表 (水滴商店)
   */
  public static async getWaterShop(): Promise<WaterShopItem[]> {
    const shopItems: WaterShopItem[] = [];
    const baseUrl = ApiClient.getInstance().baseUrl;
    ;

    try {
      // 1. 构造请求
      const params: Record<string, string> = {
        'mod': 'magic',
        'action': 'shop'
      };

      // 2. 获取 HTML
      const doc: Document = await ApiClient.getInstance().requestHtml('home.php', params);

      // 3. 解析
      // 查找列表容器: <ul class="mtm mgcl cl">
      const listUl = DomUtils.findOne((elem) => {
        return elem.tagName === 'ul' &&
          !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('mgcl'));
      }, doc.children, true);

      if (!listUl) {
        return shopItems;
      }

      // 查找所有 li
      const lis = DomUtils.findAll((elem) => elem.tagName === 'li', listUl.children);

      lis.forEach((li) => {
        const item = new WaterShopItem();

        // --- 1. 图标 (div.mg_img > img) ---
        const imgDiv = DomUtils.findOne((elem) => {
          return elem.tagName === 'div' &&
            !!(elem.attribs && elem.attribs['class'] && elem.attribs['class'].includes('mg_img'));
        }, li.children);

        if (imgDiv) {
          const img = DomUtils.findOne((elem) => elem.tagName === 'img', imgDiv.children);
          if (img && img.attribs && img.attribs['src']) {
            let src = img.attribs['src'];
            if (!src.startsWith('http')) {
              src = baseUrl + '/' + src;
            }
            item.shop_icon = src;
          }
        }

        // --- 2. 名称 (p > strong) ---
        // 通常是第一个 p 标签
        const pTags = DomUtils.findAll((elem) => elem.tagName === 'p', li.children);

        // 第一个 p 通常是名称
        if (pTags.length > 0) {
          const strong = DomUtils.findOne((elem) => elem.tagName === 'strong', pTags[0].children);
          if (strong) {
            item.shop_name = DomUtils.textContent(strong).trim();
          }
        }

        // --- 3. 价格 (第二个 p, 内容类似 "水滴 5 滴/张") ---
        if (pTags.length > 1) {
          const priceText = DomUtils.textContent(pTags[1]).trim();
          // 匹配数字
          const match = priceText.match(/(\d+)/);
          if (match) {
            item.shop_price = parseInt(match[1]);
          }
        }

        // --- 4. 购买链接与状态 (查找 a 标签, href 包含 mid=) ---
        const buyLink = DomUtils.findOne((elem) => {
          return elem.tagName === 'a' &&
            !!(elem.attribs && elem.attribs['href'] && elem.attribs['href'].includes('mid='));
        }, li.children, true);

        if (buyLink) {
          item.can_buy = true;
          // 提取 mid
          const href = buyLink.attribs['href'];
          const midMatch = href.match(/mid=([^&]+)/);
          if (midMatch) {
            item.shop_mid = midMatch[1];
          }
        } else {
          item.can_buy = false;
          item.shop_mid = "";
        }

        shopItems.push(item);
      });

    } catch (e) {
      LogUtil.error(TAG, 'getWaterShop failed', JSON.stringify(e));
    }

    return shopItems;
  }
}