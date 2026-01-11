import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant, UiState, WaterMission, WaterMissionState } from 'base_common';
import { StateLayout } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';

@ComponentV2
export struct WaterEarnWater {
  @Param @Require vm: WaterVM;
  @Local missions: WaterMission[] = [];
  @Local isLoadingMission: UiState = UiState.LOADING;

  getStateColor(state: WaterMissionState): ResourceColor {
    if (state === WaterMissionState.NEW) {
      return CommonConstant.ThemeColor;
    } else if (state === WaterMissionState.DOING) {
      return CommonConstant.InfoColor;
    } else if (state == WaterMissionState.FINISH) {
      return CommonConstant.SuccessColor;
    } else {
      return $r('sys.color.font_tertiary');
    }
  }

  getStateFont(state: WaterMissionState): ResourceStr {
    if (state === WaterMissionState.NEW) {
      return $r('app.string.WaterPage_mission_new');
    } else if (state === WaterMissionState.DOING) {
      return $r('app.string.WaterPage_mission_doing');
    } else if (state == WaterMissionState.FINISH) {
      return $r('app.string.WaterPage_mission_finish');
    } else {
      return $r('app.string.WaterPage_mission_fail');
    }
  }

  async aboutToAppear() {
    this.missions = await this.vm.getMissions();

    if (this.missions.length > 0) {
      this.isLoadingMission = UiState.SUCCESS;
    } else {
      this.isLoadingMission = UiState.EMPTY;
    }
  }

  @Builder
  missionBandage(state: WaterMissionState) {
    Row() {
      Text(this.getStateFont(state))
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor(this.getStateColor(state))
    }
    .padding({
      top: CommonConstant.SmallContainerInnerPadding / 2,
      bottom: CommonConstant.SmallContainerInnerPadding / 2,
      left: CommonConstant.SmallContainerInnerPadding,
      right: CommonConstant.SmallContainerInnerPadding
    })
    .borderRadius(CommonConstant.FullPercent)
    .border({ width: CommonConstant.BorderSizeNormal, color: this.getStateColor(state) })
  }

  @Builder
  MissionCard(mission: WaterMission) {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Image(mission.mission_icon)
        .width(CommonConstant.IconSizeLarge)
        .height(CommonConstant.IconSizeLarge)
        .borderRadius(CommonConstant.RadiusNormal)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Row() {
          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            Text(mission.mission_name)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontWeight(FontWeight.Medium)

            this.missionBandage(mission.mission_state)
          }

          Text(`${ResUtil.getStringSync($r('app.string.WaterPage_mission_hot'))} ${mission.mission_hot.toString()}`)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(mission.mission_reward_value)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstant.WarningColor)

          Text(mission.mission_reward)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }

        if (mission.mission_desc) {
          Text(mission.mission_desc)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_secondary'))
        }

        if (mission.mission_progress !== undefined) {
          Progress({ value: mission.mission_progress })
            .color(CommonConstant.ThemeColor)
            .style({ strokeWidth: CommonConstant.BorderSizeHuge })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(CommonConstant.FullPercent)
    .alignItems(VerticalAlign.Top)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .borderRadius(CommonConstant.RadiusNormal)
    .backgroundColor($r('app.color.start_window_background'))
    .opacity(mission.mission_state === WaterMissionState.FAIL ? 0.3 : 1)
  }

  build() {
    StateLayout({
      uiState: this.isLoadingMission
    }) {
      Refresh({ refreshing: $$this.vm.isRefreshMission }) {
        WaterFlow() {
          ForEach(this.missions, (mission: WaterMission, index: number) => {
            FlowItem() {
              this.MissionCard(mission)
            }
            .width(CommonConstant.FullPercent)
          }, (mission: WaterMission, index: number) => index.toString())
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .columnsTemplate('1fr '.repeat(this.vm.columns)
          .trim())
        .columnsGap(CommonConstant.NormalContainerInnerPadding)
        .rowsGap(CommonConstant.NormalContainerInnerPadding)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .onRefreshing(async () => {
        this.missions = await this.vm.getMissions();
      })
    }
  }
}