import { AppStorageV2 } from '@kit.ArkUI';
import { ToastItem, ToastManager, ToastStore } from 'base_common';

@ComponentV2
export struct ToastHost {
  @Local store: ToastStore = AppStorageV2.connect(ToastStore, () => new ToastStore())!;

  private getBottomOffset(): number {
    const queue = this.store.queue;
    if (!queue || queue.length === 0) {
      return 0;
    }
    return queue[queue.length - 1].bottomOffset;
  }

  @Builder
  private RenderItem(item: ToastItem) {
    Row({ space: 10 }) {
      Text(ToastManager.getVisualStyle(item.type).icon)
        .fontSize(18)
        .lineHeight(22)

      Text(item.message)
        .fontSize(16)
        .fontColor(ToastManager.getVisualStyle(item.type)
          .textColor)
        .lineHeight(22)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(ToastManager.getVisualStyle(item.type)
      .bgColor)
    .borderRadius(14)
    .shadow({
      radius: 12,
      color: '#26000000',
      offsetX: 0,
      offsetY: 4
    })
    .width('100%')
    .opacity(0.98)
  }

  build() {
    Navigation() {
      if (!this.store.queue || this.store.queue.length === 0) {
        Blank()
      }
      else {
        Column({ space: 10 })
        {
          ForEach(this.store.queue, (item: ToastItem) => {
            this.RenderItem(item);
          }, (item: ToastItem) => item.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: this.getBottomOffset() })
        .align(Alignment.Bottom)
      }
    }
  }
}