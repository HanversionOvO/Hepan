import { BaseVM, CommonConstant } from 'base_common';
import { CustomTabBar, CustomTabItem } from './CustomTabBar';
import { util } from '@kit.ArkTS';
import { AppUtil } from '@pura/harmony-utils';

// 定义 JSON 数据的接口结构
interface FaceCollectionData {
  collection_name: string;
  collection_icon: string;
  base_url: string;
  collections: string[];
}

@ComponentV2
export struct CustomFacePanel {
  @Param @Require vm: BaseVM;
  // 用于存储从 JSON 解析出的原始数据
  @Local faceCollections: FaceCollectionData[] = [];
  // 用于传递给 CustomTabBar 的数据
  @Local tabItems: CustomTabItem[] = [];
  // 当前选中的 Tab 索引
  @Local currentIndex: number = 0;

  aboutToAppear(): void {
    this.loadFaceData();
  }

  /**
   * 从 rawfile 加载 data.json 数据
   */
  async loadFaceData() {
    try {
      // 获取 ResourceManager
      const context = AppUtil.getContext();
      const resourceManager = context.resourceManager;

      // 读取 rawfile 中的 data.json
      const content = await resourceManager.getRawFileContent('faces.json');

      // 解码二进制数据
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const jsonString = textDecoder.decodeWithStream(content);

      // 解析 JSON
      const data = JSON.parse(jsonString) as FaceCollectionData[];
      this.faceCollections = data;

      // 转换为 CustomTabBar 需要的格式
      this.tabItems = data.map((item): CustomTabItem => {
        return {
          label: item.collection_name,
          icon: $r('sys.symbol.capture_smiles')
        };
      });

    } catch (error) {
      console.error(`CustomFacePanel load data failed: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      // 只有当数据加载完成后才渲染
      if (this.tabItems.length > 0) {
        CustomTabBar({
          vm: this.vm,
          tabItems: this.tabItems,
          currentIndex: this.currentIndex, // 绑定当前索引
          isMax: true,
          alignMode: FlexAlign.Start,
          changeTab: (index: number) => {
            this.currentIndex = index; // 点击 Tab 时更新索引
          }
        })

        Tabs({ index: this.currentIndex }) { // 绑定当前索引
          ForEach(this.faceCollections, (collection: FaceCollectionData) => {
            TabContent() {
              // 表情列表区域
              Grid() {
                ForEach(collection.collections, (imgName: string) => {
                  GridItem() {
                    Image(collection.base_url + imgName) // 拼接 URL
                      .width(CommonConstant.IconSizeLarge)
                      .height(CommonConstant.IconSizeLarge)
                      .objectFit(ImageFit.Contain)
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr') // 5列展示
              .rowsGap(CommonConstant.NormalContainerInnerPadding)
              .columnsGap(CommonConstant.NormalContainerInnerPadding)
              .width(CommonConstant.FullPercent)
              .height(CommonConstant.FullPercent)
            }
          })
        }
        .layoutWeight(1)
        .barHeight(0)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      } else {
        // 数据加载中的占位
        LoadingProgress()
          .width(CommonConstant.IconSizeLarge)
          .height(CommonConstant.IconSizeLarge)
          .color(CommonConstant.ThemeColor)
      }
    }
    .width(CommonConstant.FullPercent)
    .height(this.vm.window.windowHeight * 0.4)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius({
      topLeft: CommonConstant.RadiusUltraLarge,
      topRight: CommonConstant.RadiusUltraLarge
    })
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
  }
}