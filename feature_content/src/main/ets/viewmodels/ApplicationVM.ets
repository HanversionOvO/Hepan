import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, BreakpointNameEnum, BreakpointType, CommonConstant, RouterMap, RouterUtil } from 'base_common';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { ApplicationCardItem } from '../components/ApplicationCard';
import { curves } from '@kit.ArkUI';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'base_ui';

@ObservedV2
export class ApplicationVM extends BaseVM {
  @Trace applications: ApplicationCardItem[] = [];
  @Trace columns: number = 2;
  @Trace pageScale: number = 1;

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  private defaultColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
  }

  async loadData() {
    const waterApplication: ApplicationCardItem = new ApplicationCardItem({
      id: "water_application",
      icon: $r('sys.symbol.drop_fill'),
      name: $r('app.string.ApplicationPage_Water'),
      iconColor: CommonConstant.InfoColor,
      desc: $r('app.string.ApplicationPage_Water_desc'),
      route: RouterMap.WATER_PAGE
    })

    this.applications = [waterApplication];

    this.updateGridConfig(this.breakPoint.currentBreakPoint)
  }

  enterPage(componentId: string, route: RouterMap, context: UIContext, param?: Record<string, Object>) {
    let options: LongTakeTransitionOptions = {
      onEnterTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 0.8;
        })
      },
      onBackTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 1.0;
        })
      }
    };

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(AppUtil.getUIContext(),
        componentId, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    if (param) {
      params["param"] = param;
    }

    RouterUtil.pushPathByName(route, params);
  }
}