import { ComponentContent, PromptAction, window } from '@kit.ArkUI';
import { CommonConstant, getComponentsInfo, getSizeByUnit } from 'base_common';

type PreviewImgType = PixelMap | ResourceStr | DrawableDescriptor

/**
 * 对齐方式
 */
export enum PreviewVerticalAlign {
  Top = 'top',
  Bottom = 'bottom',
}


@ObservedV2
class ImagePreviewOption {
  /**
   * 是否简单模式，不展示评论、点赞、分享、关注等功能
   */
  isBasicMode?: boolean = false
  /**
   * 遮罩背景色
   */
  maskColor?: ResourceColor = $r('app.color.glass_background')
  /**
   * 背景模糊样式
   */
  blurStyle?: BlurStyle = BlurStyle.BACKGROUND_ULTRA_THICK
  /**
   * 指定初始显示的图片索引
   */
  startIndex?: number = 0
  /**
   * 动画时长
   */
  swipeDuration?: number = CommonConstant.AnimationDurationNormal
  /**
   * 是否显示页码
   */
  showIndex?: boolean = true
  /**
   * 页码位置
   */
  indexPosition?: PreviewVerticalAlign = PreviewVerticalAlign.Bottom
  /**
   * 页码距离顶部或底部距离
   */
  indexOffset?: number | string = 40
  /**
   * 页码字体颜色
   */
  indexFontColor?: ResourceColor
  /**
   * 页码字体大小
   */
  indexFontSize?: number | string = CommonConstant.TextSizeSmall
  /**
   * 是否循环
   */
  loop?: boolean = true
  /**
   * 是否启用双击缩放手势，禁用后，点击时会立即关闭图片预览
   */
  doubleScale?: boolean = true
  /**
   * 是否在点击遮罩层后关闭图片预览
   */
  closeOnClickOverlay?: boolean = true
  /**
   * 是否在点击图片后关闭图片预览
   */
  closeOnClickImage?: boolean = true
  /**
   * 最大缩放比例
   */
  maxScale?: number = 3
  /**
   * 最小缩放比例
   */
  minScale?: number = 1
  /**
   * 图片点击事件
   */
  onImgClick?: (index: number) => void
  /**
   * 图片长按事件
   */
  onImgLongPress?: (index: number) => void
  /**
   * 顶部操作栏
   */
  authorBuilder?: () => void = () => {
  }
  /**
   * 底部操作栏
   */
  operationBuilder?: () => void = () => {
  }
  /*
   * 关闭操作栏
   * */
  onCloseExpand?: () => void = () => {
  }
}

class ImagePreviewParams extends ImagePreviewOption {
  list: PreviewImgType[] = []
  // 关闭
  hide: () => void = () => {
  }

  constructor(list: PreviewImgType[], params?: ImagePreviewOption) {
    super()
    this.list = list
    this.isBasicMode = params?.isBasicMode ?? false
    this.maskColor = params?.maskColor || $r('app.color.glass_background')
    this.blurStyle = params?.blurStyle || BlurStyle.BACKGROUND_ULTRA_THICK
    this.startIndex = params?.startIndex || 0
    this.swipeDuration = params?.swipeDuration || CommonConstant.AnimationDurationNormal
    this.showIndex = params?.showIndex !== undefined ? params.showIndex : list.length >= 1
    this.indexPosition = params?.indexPosition || PreviewVerticalAlign.Bottom
    this.indexOffset = params?.indexOffset || 40
    this.indexFontColor = params?.indexFontColor || Color.White
    this.indexFontSize = params?.indexFontSize || CommonConstant.TextSizeSmall
    this.loop = params?.loop !== undefined ? params.loop : true
    this.doubleScale = params?.doubleScale !== undefined ? params.doubleScale : true
    this.closeOnClickOverlay = params?.closeOnClickOverlay !== undefined ? params.closeOnClickOverlay : true
    this.closeOnClickImage = params?.closeOnClickImage !== undefined ? params.closeOnClickImage : true
    this.maxScale = params?.maxScale || 3
    this.minScale = params?.minScale || 1
    this.onImgClick = params?.onImgClick
    this.onImgLongPress = params?.onImgLongPress
    this.authorBuilder = params?.authorBuilder
    this.operationBuilder = params?.operationBuilder
    this.onCloseExpand = params?.onCloseExpand
  }
}

@ComponentV2
struct PreviewContent {
  @Param params: ImagePreviewParams = new ImagePreviewParams([])
  @Local active: number = 0
  @Local isDisabledSwiper: boolean = false
  @Local isExpand: boolean = false

  aboutToAppear(): void {
    this.active = this.params.startIndex as number
  }

  build() {
    Stack({ alignContent: this.params.indexPosition === PreviewVerticalAlign.Top ? Alignment.Top : Alignment.Bottom }) {
      Swiper() {
        ForEach(this.params.list, (item: PreviewImgType, index: number) => {
          SwiperItem({
            url: item,
            index: index,
            active: this.active,
            params: this.params,
            isDisabledSwiper: this.isDisabledSwiper,
            onDisabledSwiper: (isDisabled: boolean) => {
              this.isDisabledSwiper = isDisabled
            },
          })
        }, (item: PreviewImgType, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .height('100%')
      .index($$this.active)
      .indicator(false)
      .loop(this.params.loop)
      .duration(this.params.swipeDuration)
      .disableSwipe(this.isDisabledSwiper)

      if (this.params.showIndex && !this.isExpand) {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          if (this.params.authorBuilder) {
            AuthorBuilder({ option: this.params })
          }

          Blank()

          Column() {
            Text(`${this.active + 1} / ${this.params.list.length}`)
              .fontColor(this.params.indexFontColor)
              .fontWeight(FontWeight.Bold)
              .fontSize(this.params.indexFontSize ? getSizeByUnit(this.params.indexFontSize, true) : '')
              .constraintSize({ minWidth: 50 })
              .textAlign(TextAlign.Center)
          }
          .backgroundColor($r('app.color.glass_background'))
          .borderRadius(CommonConstant.RadiusRound)
          .padding(CommonConstant.SmallContainerTBPadding)
        }
        .offset({
          y: `${this.params.indexPosition === PreviewVerticalAlign.Top ? '' :
            '-'}${getSizeByUnit(this.params.indexOffset)}`,
        })
        .padding({ left: 16, right: 16 })
      }
      Column() {
        if (this.params.operationBuilder) {
          OperationBuilder({ option: this.params })
        }
      }
      .position({ bottom: 28 })
      .padding({ left: 16, right: 16 })
    }
    .backgroundBlurStyle(this.params.blurStyle)
  }
}


@ComponentV2
struct OperationBuilder {
  @Require @Param option: ImagePreviewOption

  build() {
    OperationBuilderComponent({ operationBuilder: this.option.operationBuilder })
  }
}

@ComponentV2
struct OperationBuilderComponent {
  @BuilderParam operationBuilder?: () => void

  build() {
    if (this.operationBuilder) {
      this.operationBuilder()
    }
  }
}


@ComponentV2
struct AuthorBuilder {
  @Require @Param option: ImagePreviewOption

  build() {
    AuthorBuilderComponent({ authorBuilder: this.option.authorBuilder })
  }
}

@ComponentV2
struct AuthorBuilderComponent {
  @BuilderParam authorBuilder?: () => void

  build() {
    if (this.authorBuilder) {
      Column() {
        this.authorBuilder()
      }
      .margin({ top: 16 })
    }
  }
}

@ComponentV2
struct SwiperItem {
  @Param @Require params: ImagePreviewParams = new ImagePreviewParams([])
  @Require @Param url: PreviewImgType
  @Require @Param index: number
  @Require @Param active: number
  @Require @Param isDisabledSwiper: boolean
  @Local rootWidth: number = 0
  @Local rootHeight: number = 0
  @Local imgWidth: number = 0
  @Local imgHeight: number = 0
  @Local curScale: number = 1
  @Local offsetX: number = 0
  @Local offsetY: number = 0
  @Local startX: number = 0
  @Local startY: number = 0
  @Local offsetMaxX: number = 0
  @Local offsetMinX: number = 0
  @Local offsetMaxY: number = 0
  @Local offsetMinY: number = 0
  @Local imgDraggable: boolean = true
  @Local isMoving: boolean = false
  private isImageMoved: boolean = false
  private isFingerMove: boolean = false
  private lastScale: number = 1
  private lastOffsetX: number = 0
  private lastOffsetY: number = 0
  private centerX: number = 0.5
  private centerY: number = 0.5
  private center: [number, number] = [0.5, 0.5]
  private readonly defaultScaleValue: number = 1
  private isDisableSwipe: boolean = false
  private isArriveBoundary: boolean = false
  @Event onDisabledSwiper: (isDisabled: boolean) => void = () => {
  }

  @Monitor('isMoving')
  moveChange() {
    console.log('isMoving')
  }

  // 初始化
  init(width: number, height: number) {
    let comInfo = getComponentsInfo(this.getUIContext(), 'PreviewImgContent')
    this.rootWidth = comInfo.width
    this.rootHeight = comInfo.height
    let originWidth = px2vp(width)
    let originHeight = px2vp(height)
    let widthRatio = this.rootWidth / originWidth
    let heightRatio = this.rootHeight / originHeight
    let scaleRatio = Math.min(widthRatio, heightRatio)
    this.imgWidth = originWidth * scaleRatio
    this.imgHeight = originHeight * scaleRatio
    this.imgDraggable = !this.params.onImgLongPress
    this.resetState()
  }

  private resetState(): void {
    this.curScale = this.defaultScaleValue
    this.lastScale = this.defaultScaleValue
    this.offsetX = 0
    this.offsetY = 0
    this.lastOffsetX = 0
    this.lastOffsetY = 0
    this.evaluateOffsetRange()
    this.isDisableSwipe = false
    this.onDisabledSwiper(false)
  }

  private evaluateCenter(centerX: number, centerY: number): [number, number] {
    let imgDisplayWidth = this.imgWidth * this.lastScale
    let imgDisplayHeight = this.imgHeight * this.lastScale
    let imgX = (this.rootWidth - imgDisplayWidth) / 2 + this.lastOffsetX
    let imgY = (this.rootHeight - imgDisplayHeight) / 2 + this.lastOffsetY
    let cX = Math.max((centerX - imgX) / imgDisplayWidth, 0)
    let cY = Math.max((centerY - imgY) / imgDisplayHeight, 0)
    return [cX, cY]
  }

  private evaluateOffsetRange(): void {
    let scaledImageWidth = this.imgWidth * this.curScale
    let scaledImageHeight = this.imgHeight * this.curScale
    if (scaledImageWidth > this.rootWidth) {
      let maxXOffset = (scaledImageWidth - this.rootWidth) / 2
      this.offsetMaxX = maxXOffset
      this.offsetMinX = -maxXOffset
    } else {
      this.offsetMaxX = 0
      this.offsetMinX = 0
    }
    if (scaledImageHeight > this.rootHeight) {
      let maxYOffset = (scaledImageHeight - this.rootHeight) / 2
      this.offsetMaxY = maxYOffset
      this.offsetMinY = -maxYOffset
    } else {
      this.offsetMaxY = 0
      this.offsetMinY = 0
    }
  }

  private pictureBoundaryRestriction(): void {
    if (this.offsetX > this.offsetMaxX) {
      this.offsetX = this.offsetMaxX
      this.isDisableSwipe = false
      this.isArriveBoundary = true
    } else if (this.offsetX < this.offsetMinX) {
      this.offsetX = this.offsetMinX
      this.isDisableSwipe = false
      this.isArriveBoundary = true
    }
    if (this.offsetY > this.offsetMaxY) {
      this.offsetY = this.offsetMaxY
    } else if (this.offsetY < this.offsetMinY) {
      this.offsetY = this.offsetMinY
    }
    let scaledImageWidth = this.imgWidth * this.curScale
    let scaledImageHeight = this.imgHeight * this.curScale
    if (scaledImageWidth <= this.rootWidth) {
      this.offsetX = 0
    }
    if (scaledImageHeight <= this.rootHeight) {
      this.offsetY = 0
    }
  }

  private onScale(scale: number, offX: number, offY: number): void {
    const minScale = +(this.params.minScale as number)
    const maxScale = +(this.params.maxScale as number)
    if (this.lastScale * scale > maxScale) {
      this.curScale = maxScale
    } else if (this.lastScale * scale < minScale) {
      this.curScale = minScale
    } else {
      this.curScale = this.lastScale * scale
    }
    if (this.lastScale * scale === maxScale) {
      this.curScale -= 0.001
    }
    this.evaluateOffsetRange()
    if (this.curScale < maxScale) {
      this.offsetY = (this.lastOffsetY + offY) +
        (0.5 - this.centerY) * this.imgHeight * (1 - scale) * this.lastScale
      this.offsetX = (this.lastOffsetX + offX) +
        (0.5 - this.centerX) * this.imgWidth * (1 - scale) * this.lastScale
    }
    this.isArriveBoundary = false
    if (!this.isArriveBoundary) {
      this.isDisableSwipe = true
    }
  }

  private gestureEnd(): void {
    this.lastScale = this.curScale
    this.lastOffsetX = this.offsetX
    this.lastOffsetY = this.offsetY
  }

  private offsetReset(): void {
    this.offsetX = 0
    this.offsetY = 0
    this.lastOffsetX = 0
    this.lastOffsetY = 0
  }

  // 单击
  singleClick(type: 'img' | 'mask') {
    if (!this.isFingerMove) {
      !this.params.closeOnClickImage && this.params.onImgClick && this.params.onImgClick(this.index)
      if (type === 'img') {
        this.params.closeOnClickImage && this.params.hide()
      } else {
        this.params.closeOnClickOverlay && this.params.hide()
      }
    }
  }

  // 双击
  doubleClick(fingers: FingerInfo[]) {
    this.params?.onCloseExpand?.()
    if (!this.isFingerMove) {
      if (this.params.doubleScale) {
        const maxScale = +(this.params.maxScale as number)
        this.center = this.evaluateCenter(fingers[0].localX, fingers[0].localY)
        this.centerX = 1 - this.center[0]
        this.centerY = 1 - this.center[1]
        if (this.lastScale > this.defaultScaleValue) {
          this.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.Smooth },
            () => {
              this.curScale = this.defaultScaleValue
              this.offsetReset()
            })
          this.lastScale = this.defaultScaleValue
          this.isDisableSwipe = false
        } else {
          this.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.Smooth },
            () => {
              this.curScale = maxScale
              this.offsetReset()
            })
          this.lastScale = maxScale
          this.isDisableSwipe = true
        }
        this.onDisabledSwiper(this.isDisableSwipe)
      } else {
        this.params.closeOnClickImage && this.params.hide()
      }
    }
  }

  // 手指移动
  onFingerMove(event: TouchEvent) {
    switch (event.type) {
      case TouchType.Down:
        this.isMoving = this.curScale > this.defaultScaleValue || this.offsetMaxX !== 0 || this.offsetMaxY !== 0
        this.startX = event.touches[0].x
        this.startY = event.touches[0].y
        this.isImageMoved = false
        this.isFingerMove = false
        break
      case TouchType.Move:
        let x = event.touches[0].x - this.startX
        let y = event.touches[0].y - this.startY
        this.isFingerMove = x !== 0 || y !== 0
        if (!this.isMoving) {
          return
        }
        this.isImageMoved = true
        this.onScale(1, x, y)
        this.pictureBoundaryRestriction()
        this.onDisabledSwiper(this.isDisableSwipe)
        break
      case TouchType.Up:
        this.isMoving = false
        this.gestureEnd()
        break
    }
  }

  // 重置
  @Monitor('active')
  reset() {
    this.resetState()
  }

  build() {
    Row() {
      Image(this.url)
        .width(this.imgWidth > 0 ? this.imgWidth : '100%')
        .height(this.imgHeight > 0 ? this.imgHeight : '100%')
        .objectFit(ImageFit.Contain)
        .scale({ x: this.curScale, y: this.curScale, z: 1 })
        .translate({ x: this.offsetX, y: this.offsetY, z: 0 })
        .draggable(this.imgDraggable)
        .animation({
          duration: 100,
        })
        .onComplete((event) => {
          if (event) {
            this.init(event.contentWidth, event.contentHeight)
          }
        })
        .gesture(
          // 长按
          LongPressGesture({ fingers: 1 }).onAction(() => {
            this.params.onImgLongPress && this.params.onImgLongPress(this.index)
          }),
        )
    }
    .justifyContent(FlexAlign.Center)
    .id('PreviewImgContent')
    .onTouch((event) => {
      this.onFingerMove(event)
    })
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        // 双击
        TapGesture({ fingers: 1, count: 2 }).onAction((event) => {
          this.doubleClick(event.fingerList)
        }),
        // 单击
        TapGesture({ fingers: 1, count: 1 }).onAction(() => {
          this.singleClick('mask')
        }),
        // 缩放
        PinchGesture({ fingers: 2 })
          .onActionStart((event: GestureEvent) => {
            this.params?.onCloseExpand?.()
            this.center = this.evaluateCenter(event.pinchCenterX, event.pinchCenterY)
            this.centerX = 1 - this.center[0]
            this.centerY = 1 - this.center[1]
          })
          .onActionUpdate((event: GestureEvent) => {
            this.isMoving = false
            this.onScale(event.scale, event.offsetX, event.offsetY)
            this.pictureBoundaryRestriction()
            if (this.curScale > this.defaultScaleValue) {
              this.isDisableSwipe = true
            }
            this.onDisabledSwiper(this.isDisableSwipe)
          })
          .onActionEnd(() => {
            const maxZoom = +(this.params.maxScale as number)
            if (this.curScale <= this.defaultScaleValue) {
              this.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.Smooth },
                () => {
                  this.curScale = this.defaultScaleValue
                  this.offsetReset()
                })
              this.isDisableSwipe = false
            } else if (this.curScale >= maxZoom) {
              this.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.Smooth },
                () => {
                  this.curScale = maxZoom
                })
              this.isDisableSwipe = true
            }
            this.gestureEnd()
            this.onDisabledSwiper(this.isDisableSwipe)
          }),
      ),
    )
  }
}

@Builder
function previewBuilder(params: ImagePreviewParams) {
  PreviewContent({ params })
}

class ImagePreview {
  private static _instance: ImagePreview = new ImagePreview()
  private contentNode: ComponentContent<ImagePreviewParams> | null = null
  private promptAction: PromptAction | null = null

  private getInstance(contentNode: ComponentContent<ImagePreviewParams>,
    promptAction: PromptAction): ImagePreview {
    if (!ImagePreview._instance) {
      ImagePreview._instance = new ImagePreview()
    }
    ImagePreview._instance.contentNode = contentNode
    ImagePreview._instance.promptAction = promptAction
    return ImagePreview._instance
  }

  /**
   * 显示预览
   */
  public async show(list: PreviewImgType[], option?: ImagePreviewOption) {
    let opt: ImagePreviewParams = new ImagePreviewParams(list, option)
    opt.hide = (): void => this.hide()
    if (ImagePreview._instance.contentNode) {
      this.hide()
    }
    let windowClass = await window.getLastWindow(getContext())
    let systemBarProperty = windowClass.getWindowSystemBarProperties()
    AppStorage.setOrCreate('statusBarContentColor', systemBarProperty.statusBarContentColor)
    let uiContext = windowClass.getUIContext()
    let contentNode = new ComponentContent(uiContext, wrapBuilder(previewBuilder), opt)
    let promptAction = uiContext.getPromptAction()
    ImagePreview._instance = this.getInstance(contentNode, promptAction)
    promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center,
      isModal: true,
      maskColor: opt.maskColor,
      autoCancel: false,
      onDidAppear: () => {
        windowClass.setWindowSystemBarProperties({
          statusBarContentColor: '#ffffff',
        })
      },
      onWillDisappear: () => {
        let mainStatusBarContentColor: string = AppStorage.get('statusBarContentColor') ?? '#ffffff'
        windowClass.setWindowSystemBarProperties({
          statusBarContentColor: mainStatusBarContentColor,
        })
      },
    })
  }

  /**
   * 关闭预览
   */
  public hide() {
    if (ImagePreview._instance.contentNode) {
      ImagePreview._instance.promptAction?.closeCustomDialog(ImagePreview._instance.contentNode)
      ImagePreview._instance.contentNode?.dispose()
      ImagePreview._instance.contentNode = null
    }
  }
}

const imagePreview = new ImagePreview()

export { imagePreview }
