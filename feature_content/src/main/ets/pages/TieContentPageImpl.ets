import { CommonConstant, ForumTieSummary } from 'base_common';
import { CardLongTakeDelegate, LongTakeTransitionParam } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct TieContentPageImpl {
  @Local vm: TieContentPageVM = new TieContentPageVM();

  @Builder
  ContentBuilder() {
    Column() {
      Text("test")
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
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

        if (params["tieSummary"]) {
          this.vm.tieSummary = params["tieSummary"] as ForumTieSummary;
        }

        await this.vm.loadData();
      }
    })
  }
}