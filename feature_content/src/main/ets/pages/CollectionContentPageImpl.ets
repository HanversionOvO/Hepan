import { Collection } from 'base_common'
import { CardLongTakeDelegate, LongTakeTransitionParam } from 'base_ui'
import { CollectionContentPageVM } from '../viewmodels/CollectionContentPageVM'
import { CollectionContentView } from '../views/CollectionContentView'

@ComponentV2
export struct CollectionContentPageImpl {
  @Local vm: CollectionContentPageVM = new CollectionContentPageVM()

  @Builder
  ContentBuilder() {
    CollectionContentView({ vm: this.vm })
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

        if (params["collection"]) {
          this.vm.collection = params["collection"] as Collection;
        }

        await this.vm.loadData();
      }
    })
  }
}