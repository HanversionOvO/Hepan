import { Document, DomUtils } from '@ohos/htmlparser2';
import { ApiClient } from './ApiClient';
import { WaterModels, WaterRecord } from './models/WaterModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[WaterApi]: ';

export class WaterApi {
  /**
   * 获取水滴概况及记录
   * 1. 访问 op=base 获取当前水滴数
   * 2. 访问 op=log 获取水滴变更记录
   */
  public static async getWaterSummary(): Promise<WaterModels> {
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
        'income': 0,
        'search': true
      };

      const logDoc: Document = await ApiClient.getInstance().requestHtml(
        'home.php',
        logParams,
        http.RequestMethod.POST
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
}