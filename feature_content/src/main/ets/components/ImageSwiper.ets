import { AppPreferenceKeys, CommonConstant, PreferenceUtil, SummaryAttachments, UrlUtil } from 'base_common';
import { ImageLongTakePreviewUtil } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

interface PreviewImageItem {
  displayUrl: string;
  previewUrl: string;
}

@ComponentV2
export struct ImageSwiper {
  @Param @Require vm: TieContentPageVM;
  @Param @Require swiperHeight: number;
  @Local baseUrl: string = CommonConstant.BASE_URL;
  @Local previewingUrl: string = '';

  @Computed
  get imageItems(): PreviewImageItem[] {
    return this.getImageItems();
  }

  aboutToAppear(): void {
    this.loadBaseUrl();
  }

  private loadBaseUrl(): void {
    const storedBaseUrl = PreferenceUtil.read<string>(AppPreferenceKeys.prefName, (pref) => {
      return pref.getSync(AppPreferenceKeys.baseUrl, CommonConstant.BASE_URL) as string;
    }, CommonConstant.BASE_URL);
    this.baseUrl = storedBaseUrl ? storedBaseUrl : CommonConstant.BASE_URL;
  }

  private buildFullUrl(path: string): string {
    return UrlUtil.buildUrl(this.baseUrl, path);
  }

  private getPreviewUrl(attachment: SummaryAttachments): string {
    const path = attachment.raw_url || attachment.download_url || attachment.path || attachment.thumbnail_url;
    if (!path) {
      return '';
    }
    return this.buildFullUrl(path);
  }

  private getDisplayUrl(attachment: SummaryAttachments): string {
    const path = attachment.thumbnail_url || attachment.raw_url || attachment.download_url || attachment.path;
    if (!path) {
      return '';
    }
    return this.buildFullUrl(path);
  }

  private getImageItems(): PreviewImageItem[] {
    const attachments = this.vm.tieSummary?.summary_attachments || [];
    const items: PreviewImageItem[] = [];
    attachments.forEach((attachment) => {
      if (attachment.is_image) {
        const previewUrl = this.getPreviewUrl(attachment);
        if (!previewUrl) {
          return;
        }
        const displayUrl = this.getDisplayUrl(attachment) || previewUrl;
        items.push({ displayUrl, previewUrl });
      }
    });
    return items;
  }

  private getComponentId(): string {
    return `tie_swiper_${this.vm.tieSummary?.thread_id || 0}`;
  }

  private showPreview(items: PreviewImageItem[], index: number): void {
    if (!items || items.length === 0) {
      return;
    }
    const images = items.map((item) => item.previewUrl);
    const selectedIndex = Math.max(0, Math.min(index, images.length - 1));
    const selectedUrl = images[selectedIndex];
    ImageLongTakePreviewUtil.show({
      uiContext: this.getUIContext(),
      componentId: this.getComponentId(),
      imageList: images,
      selectedIndex: selectedIndex,
      onShowAction: () => {
        this.previewingUrl = selectedUrl;
      },
      onBackToFirstPage: () => {
        this.previewingUrl = '';
      }
    });
  }

  build() {
    Stack() {
      if (this.imageItems.length > 0) {
        Swiper() {
          ForEach(this.imageItems, (item: PreviewImageItem, index: number) => {
            Image(item.displayUrl)
              .objectFit(ImageFit.Cover)
              .height(CommonConstant.FullPercent)
              .width(CommonConstant.FullPercent)
              .geometryTransition(item.previewUrl + this.getComponentId())
              .visibility(this.previewingUrl === item.previewUrl ? Visibility.Hidden : Visibility.Visible)
              .onClick(() => {
                this.showPreview(this.imageItems, index);
              })
          }, (item: PreviewImageItem, index: number) => `${index}_${item.previewUrl}`)
        }
        .indicator(false)
        .onChange((index: number) => {
          this.vm.currentImageIndex = index;
        })
      }

      if (this.imageItems.length > 0) {
        Row() {
          Text(`${this.vm.currentImageIndex + 1} / ${this.imageItems.length}`)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_on_primary'))
        }
        .borderRadius(CommonConstant.RadiusRound)
        .backgroundColor(Color.Transparent)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
        .padding({
          left: CommonConstant.SmallContainerLRPadding,
          right: CommonConstant.SmallContainerLRPadding,
          top: CommonConstant.SmallContainerTBPadding,
          bottom: CommonConstant.SmallContainerTBPadding
        })
        .position({
          right: CommonConstant.PageLRPadding,
          bottom: CommonConstant.NormalContainerTBPadding + CommonConstant.RadiusUltraLarge
        })
      }
    }
    .width(CommonConstant.FullPercent)
    .height(this.swiperHeight)
  }
}
