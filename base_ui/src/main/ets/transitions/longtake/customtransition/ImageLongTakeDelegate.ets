import { inspector, matrix4, window } from '@kit.ArkUI';
import { CommonConstant } from 'base_common';

enum Status {
  IDLE,
  PINCHING,
  PAN_ONLY,
  READY_TO_BACK
}

@ComponentV2
export struct ImageLongTakeDelegate {
  @Param componentId: string = ''
  @Param newsId: string = ''
  @Local status: Status = Status.IDLE;
  @Local panDirection: PanDirection = PanDirection.Vertical;
  @Local imageScale: number = 1;
  @Local imagePullingDownScale: number = 1;
  @Local imageTranslateX: number = 0;
  @Local imageTranslateY: number = 0;
  @Local maxOffsetX: number = 0;
  @Local minOffsetX: number = 0;
  @Local maxOffsetY: number = 0;
  @Local minOffsetY: number = 0;
  @Local gestureDisabled: boolean = false;
  @Local gestureCount: number = 0;
  @Event onPullingScaleChange: (scale: number) => void = () => {
  };

  @Monitor('gestureCount')
  onAllGestureFinishFn() {
    this.onAllGestureFinish()
  }

  @Local geometryPositionX: number = 0;
  @Local geometryPositionY: number = 0;
  @Local geometryScale: number = 1;
  @Param imageUrl: string = '';
  private photoId: string = 'myCat';
  private photoListener: inspector.ComponentObserver =
    this.getUIContext().getUIInspector().createComponentObserver(this.photoId);
  private imagePositionX: number = 0;
  private imagePositionY: number = 600;
  private imageShownScaleRate: number = 0.8;
  private maxScale: number = 3;
  private lastScale: number = 1;
  private lastOffsetX: number = 0;
  private lastOffsetY: number = 0;
  private centerX: number = 0.5;
  private centerY: number = 0.5;
  private center: [number, number] = [0.5, 0.5];
  private readonly defaultScaleValue: number = 1;
  private componentWidth: number = 0;
  private componentHeight: number = 0;
  private imageWidthVp: number = 0;
  private imageHeightVp: number = 0;
  private panOnlyGesture: boolean = false;
  @Local imageWidth: number = 1260;

  @Monitor('imageWidth')
  getImageWidthFn() {
    this.getImageWidth()
  }

  private imageHeight: number = 1680;
  private startGestureOffsetX: number = 0;
  private startGestureOffsetY: number = 0;
  private firstStarted = true;
  @Event backToFirstPage: () => void = () => {
  };

  init(): void {
    let photoInfo = this.getUIContext().getComponentUtils().getRectangleById(this.photoId);
    this.imagePositionX = photoInfo.windowOffset.x;
    this.imagePositionY = photoInfo.windowOffset.y;
  }

  getImageWidth() {
    window.getLastWindow(this.getUIContext().getHostContext()).then((data) => {
      let properties = data?.getWindowProperties();
      if (!properties) {
        return;
      }
      this.imageWidth = properties.windowRect.width * this.imageShownScaleRate;
      this.imageHeight = properties.windowRect.height * this.imageShownScaleRate;
      this.componentWidth = this.getUIContext().px2vp(properties.windowRect.width);
      this.componentHeight = this.getUIContext().px2vp(properties.windowRect.height);
      this.imageWidthVp = this.getUIContext().px2vp(this.imageWidth);
      this.imageHeightVp = this.getUIContext().px2vp(this.imageHeight);
      const imageSize: window.Size = {
        width: this.imageWidthVp,
        height: this.imageHeightVp
      };
      const windowSize: window.Size = {
        width: this.componentWidth,
        height: this.componentHeight
      };
      this.maxScale = this.calcFitScaleRatio(imageSize, windowSize);
      this.updateExtremeOffset();
      this.updatePanDirection();
    });
  }

  onAllGestureFinish(): void {
    if (this.firstStarted) {
      this.firstStarted = false;
      return;
    }

    if (this.gestureCount !== 0) {
      return;
    }

    if (this.status === Status.IDLE) {
      this.panOnlyGesture = false;
      this.disableGesture();
      animateTo({
        duration: 200,
        curve: Curve.Smooth,
        onFinish: () => {
          this.updatePanDirection();
          this.gestureEnd();
          this.resumeGesture();
          this.onPullingScaleChange(1);
        },
      }, () => {
        this.settleImageBounds();
      })
    }

    if (this.status === Status.READY_TO_BACK) {
      this.status = Status.IDLE;
      this.disableGesture();

      this.animateBackToFirstPage();
    }
  }

  animateBackToFirstPage(): void {
    this.disableGesture();
    this.getUIContext().animateTo({
      duration: 0,
      curve: CommonConstant.AnimationCurveSpring,
      onFinish: () => {
        this.backToFirstPage();
      },
    }, () => {
    });
  }

  disableGesture(): void {
    this.gestureDisabled = true;
  }

  resumeGesture(): void {
    this.gestureDisabled = false;
  }

  calculateLeftTopPoint(): [number, number] {
    let scaledWidth = this.imageWidthVp * this.imageScale;
    let scaledHeight = this.imageHeightVp * this.imageScale;
    let left = (this.componentWidth - scaledWidth) / 2 + this.imageTranslateX;
    let top = (this.componentHeight - scaledHeight) / 2 + this.imageTranslateY;
    return [left, top];
  }

  calculateRightBottomPoint(): [number, number] {
    let scaledWidth = this.imageWidthVp * this.imageScale;
    let scaledHeight = this.imageHeightVp * this.imageScale;
    let leftTop = this.calculateLeftTopPoint();
    return [leftTop[0] + scaledWidth, leftTop[1] + scaledHeight];
  }

  private evaluateCenter(centerX: number, centerY: number): [number, number] {
    let imgDisplayWidth = this.imageWidthVp * this.lastScale;
    let imgDisplayHeight = this.imageHeightVp * this.lastScale;
    let imgX = (this.componentWidth - imgDisplayWidth) / 2 + this.lastOffsetX;
    let imgY = (this.componentHeight - imgDisplayHeight) / 2 + this.lastOffsetY;
    let cX = Math.max((centerX - imgX) / imgDisplayWidth, 0);
    let cY = Math.max((centerY - imgY) / imgDisplayHeight, 0);
    return [cX, cY];
  }

  updateExtremeOffset() {
    let scaledWidth = this.imageWidthVp * this.imageScale;
    let scaledHeight = this.imageHeightVp * this.imageScale;
    if (scaledWidth > this.componentWidth) {
      let maxXOffset = (scaledWidth - this.componentWidth) / 2;
      this.maxOffsetX = maxXOffset;
      this.minOffsetX = -maxXOffset;
    } else {
      this.maxOffsetX = 0;
      this.minOffsetX = 0;
    }
    if (scaledHeight > this.componentHeight) {
      let maxYOffset = (scaledHeight - this.componentHeight) / 2;
      this.maxOffsetY = maxYOffset;
      this.minOffsetY = -maxYOffset;
    } else {
      this.maxOffsetY = 0;
      this.minOffsetY = 0;
    }
  }

  private calcFitScaleRatio(imageSize: window.Size, windowSize: window.Size): number {
    let ratio: number = 1.0;
    if (windowSize.width > imageSize.width) {
      ratio = windowSize.width / imageSize.width;
    } else {
      ratio = windowSize.height / imageSize.height;
    }
    return ratio + 0.5;
  }

  // 双击
  doubleClick() {
    this.getUIContext().animateTo({
      duration: CommonConstant.AnimationDurationNormal,
      curve: Curve.Smooth
    }, () => {
      if (this.lastScale > this.defaultScaleValue) {
        this.imageScale = this.defaultScaleValue;
        this.offsetReset();
        this.lastScale = this.defaultScaleValue;
      } else {
        this.imageScale = this.maxScale;
        this.offsetReset();
        this.lastScale = this.maxScale;
      }
      this.updateExtremeOffset();
    })
    this.updatePanDirection();
  }

  // 单击
  singleClick() {
    this.backToFirstPage()
  }

  updatePanDirection(): void {
    this.panDirection = PanDirection.Vertical;
    let leftTop = this.calculateLeftTopPoint();
    let rightBottom = this.calculateRightBottomPoint();
    if (leftTop[0] < -1) {
      this.panDirection = this.panDirection | PanDirection.Right;
    }
    if (rightBottom[0] > this.componentWidth + 1) {
      this.panDirection = this.panDirection | PanDirection.Left;
    }
  }

  resetTransform(): void {
    this.imageTranslateX = 0;
    this.imageTranslateY = 0;
    this.imageScale = this.defaultScaleValue;
    this.imagePullingDownScale = 1;
    this.centerX = 0.5;
    this.centerY = 0.5;
    this.lastScale = this.defaultScaleValue;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.updateExtremeOffset();
    this.onPullingScaleChange(1);
  }

  private settleImageBounds(): void {
    this.imagePullingDownScale = 1;
    this.updateExtremeOffset();
    if (this.imageTranslateX > this.maxOffsetX) {
      this.imageTranslateX = this.maxOffsetX;
    } else if (this.imageTranslateX < this.minOffsetX) {
      this.imageTranslateX = this.minOffsetX;
    }
    if (this.imageTranslateY > this.maxOffsetY) {
      this.imageTranslateY = this.maxOffsetY;
    } else if (this.imageTranslateY < this.minOffsetY) {
      this.imageTranslateY = this.minOffsetY;
    }
    let scaledWidth = this.imageWidthVp * this.imageScale;
    let scaledHeight = this.imageHeightVp * this.imageScale;
    if (scaledWidth <= this.componentWidth) {
      this.imageTranslateX = 0;
    }
    if (scaledHeight <= this.componentHeight) {
      this.imageTranslateY = 0;
    }
  }

  private pictureBoundaryRestriction(): void {
    if (this.imageTranslateX > this.maxOffsetX) {
      this.imageTranslateX = this.maxOffsetX;
    } else if (this.imageTranslateX < this.minOffsetX) {
      this.imageTranslateX = this.minOffsetX;
    }
    if (this.imageTranslateY > this.maxOffsetY) {
      this.imageTranslateY = this.maxOffsetY;
    } else if (this.imageTranslateY < this.minOffsetY) {
      this.imageTranslateY = this.minOffsetY;
    }
    let scaledWidth = this.imageWidthVp * this.imageScale;
    let scaledHeight = this.imageHeightVp * this.imageScale;
    if (scaledWidth <= this.componentWidth) {
      this.imageTranslateX = 0;
    }
    if (scaledHeight <= this.componentHeight) {
      this.imageTranslateY = 0;
    }
  }

  private onScale(scale: number, offX: number, offY: number): void {
    if (this.lastScale * scale > this.maxScale) {
      this.imageScale = this.maxScale;
    } else if (this.lastScale * scale < this.defaultScaleValue) {
      this.imageScale = this.defaultScaleValue;
    } else {
      this.imageScale = this.lastScale * scale;
    }
    if (this.lastScale * scale === this.maxScale) {
      this.imageScale -= 0.001;
    }
    this.updateExtremeOffset();
    if (this.imageScale < this.maxScale) {
      this.imageTranslateY = (this.lastOffsetY + offY) +
        (0.5 - this.centerY) * this.imageHeightVp * (1 - scale) * this.lastScale;
      this.imageTranslateX = (this.lastOffsetX + offX) +
        (0.5 - this.centerX) * this.imageWidthVp * (1 - scale) * this.lastScale;
    }
  }

  private gestureEnd(): void {
    this.lastScale = this.imageScale;
    this.lastOffsetX = this.imageTranslateX;
    this.lastOffsetY = this.imageTranslateY;
  }

  private offsetReset(): void {
    this.imageTranslateX = 0;
    this.imageTranslateY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
  }

  cannotPan(): boolean {
    return this.gestureDisabled;
  }

  cannotPinch(): boolean {
    return this.status === Status.PAN_ONLY || this.gestureDisabled;
  }

  aboutToAppear(): void {
    this.photoListener.on('layout', () => {
      this.init();
    });
    this.getImageWidth()
  }

  build() {
    Stack() {
      Stack() {
        Image(this.imageUrl)
          .id(this.photoId)
          .width(this.getUIContext().px2vp(this.imageWidth) * this.geometryScale)
          .height(this.getUIContext().px2vp(this.imageHeight) * this.geometryScale)
          .objectFit(ImageFit.Contain)
          .transform(matrix4.identity()
            .scale({
              x: this.imageScale * this.imagePullingDownScale,
              y: this.imageScale * this.imagePullingDownScale,
            })
            .translate({
              x: this.getUIContext().vp2px(this.imageTranslateX),
              y: this.getUIContext().vp2px(this.imageTranslateY),
            }))
          .geometryTransition(this.newsId + this.imageUrl + this.componentId)
          .transition(TransitionEffect.OPACITY)
          .position({
            x: this.getUIContext().px2vp(this.geometryPositionX),
            y: this.getUIContext().px2vp(this.geometryPositionY),
          })
      }
      .id(this.imageUrl)
      .width(this.getUIContext().px2vp(this.imageWidth))
      .height(this.getUIContext().px2vp(this.imageHeight))
      .parallelGesture(GestureGroup(GestureMode.Exclusive,
        // 双击
        TapGesture({ fingers: 1, count: 2 }).onAction((event) => {
          this.doubleClick()
        }),
        // 单击
        TapGesture({ fingers: 1, count: 1 }).onAction(() => {
          this.singleClick()
        }),
        PinchGesture()
          .onActionStart((event: GestureEvent) => {
            this.status = Status.PINCHING;
            this.center = this.evaluateCenter(event.pinchCenterX, event.pinchCenterY);
            this.centerX = 1 - this.center[0];
            this.centerY = 1 - this.center[1];
            this.gestureCount++;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.onScale(event.scale, event.offsetX, event.offsetY);
            this.pictureBoundaryRestriction();
          })
          .onActionEnd(() => {
            this.status = Status.IDLE;
            if (this.imageScale <= this.defaultScaleValue) {
              this.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.Smooth },
                () => {
                  this.imageScale = this.defaultScaleValue;
                  this.offsetReset();
                })
            } else if (this.imageScale >= this.maxScale) {
              this.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.Smooth },
                () => {
                  this.imageScale = this.maxScale;
                })
            }
            this.gestureEnd();
            this.gestureCount--;
          }),
        PanGesture({ direction: this.panDirection })
          .onActionStart((event: GestureEvent) => {
            this.panDirection = PanDirection.All;
            let leftTop = this.calculateLeftTopPoint();
            if (leftTop[1] >= 0 && this.status !== Status.PINCHING) {
              this.status = Status.PAN_ONLY;
            }
            this.panOnlyGesture = this.status === Status.PAN_ONLY;
            this.startGestureOffsetX = this.imageTranslateX;
            this.startGestureOffsetY = this.imageTranslateY;
            this.gestureCount++;
          })
          .onActionUpdate((event: GestureEvent) => {
            let offsetX = event.offsetX;
            let offsetY = event.offsetY;
            if (this.status === Status.PAN_ONLY) {
              this.imageTranslateX = this.startGestureOffsetX + offsetX;
              this.imageTranslateY = this.startGestureOffsetY + offsetY;
              this.imagePullingDownScale = 1 - Math.abs(event.offsetY) / this.getUIContext().px2vp(2720);
              this.onPullingScaleChange(this.imagePullingDownScale);
            }
            if (this.status !== Status.PAN_ONLY) {
              this.onScale(1, offsetX, offsetY);
              this.pictureBoundaryRestriction();
            }
          })
          .onActionEnd((event: GestureEvent) => {
            if (this.status === Status.PAN_ONLY) {
              if (event.offsetY > 200) {
                this.status = Status.READY_TO_BACK;
              } else {
                this.status = Status.IDLE;
              }
            }
            this.gestureEnd();
            this.gestureCount--;
          }),
      ))
      .onGestureJudgeBegin((gestureInfo: GestureInfo) => {
        if (gestureInfo.type === GestureControl.GestureType.PAN_GESTURE) {
          return this.cannotPan() ? GestureJudgeResult.REJECT : GestureJudgeResult.CONTINUE;
        }
        if (gestureInfo.type === GestureControl.GestureType.PINCH_GESTURE) {
          return this.cannotPinch() ? GestureJudgeResult.REJECT : GestureJudgeResult.CONTINUE;
        }
        return GestureJudgeResult.CONTINUE;
      })
    }
    .width('100%')
    .height('100%')
  }
}
