import { ForumTieSummary } from 'base_common';
import { CardLongTakeDelegate, LongTakeTransitionParam } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';
import { TieContentView } from '../views/TieContentView';

@ComponentV2
export struct TieContentPageImpl {
  @Local vm: TieContentPageVM = new TieContentPageVM();

  @Builder
  ContentBuilder() {
    TieContentView({ vm: this.vm })
  }

  build() {
    NavDestination() {
      if (this.vm.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.vm.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .hideTitleBar(true)
    .backgroundColor(this.vm.longTakeSession.navDestinationBgColor)
    .backdropBlur(this.vm.longTakeSession.bgBlurRadius)
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.vm.longTakeSession.setNewSize(newValue);
    })
    .onReady(async (navDestContext: NavDestinationContext) => {
      let params = navDestContext.pathInfo?.param as Record<string, Object>;
      if (params) {
        if (params["transition"]) {
          const transitionParam: LongTakeTransitionParam = params["transition"] as LongTakeTransitionParam;
          this.vm.longTakeSession.init(navDestContext, transitionParam, {
            pop: () => {
              navDestContext.pathStack.pop()
            },
          });
        }

        // 修复：兼容多种参数传递方式 (tie, tieSummary, tid)
        if (params["tieSummary"]) {
          this.vm.tieSummary = params["tieSummary"] as ForumTieSummary;
        } else if (params["tie"]) {
          this.vm.tieSummary = params["tie"] as ForumTieSummary;
        } else if (params["tid"] || params["thread_id"]) {
          // 兜底逻辑：如果只传了ID，构造一个临时的 Summary 对象，确保 loadData 能执行
          const tid = (params["thread_id"] || params["tid"]) as number;
          this.vm.tieSummary = {
            thread_id: tid,
            author_id: 0, // 默认为0，影响"只看楼主"功能，加载后可更新
            subject: '',
            forum_id: 0,
            type_id: 0,
            author: '',
            summary: '',
            dateline: 0,
            last_post: 0,
            views: 0,
            replies: 0,
            label: '',
            recommend_add: 0,
            recommend_sub: 0,
            display_order: 0
          };
        }

        await this.vm.loadData();
      }
    })
    .onResult(async (result: Record<string, boolean>) => {
      if (result) {
        const isSend = result["isSend"];
        if (isSend) {
          await this.vm.refresh()
        }
      }
    })
  }
}