import { DialogHub, PresetToast } from '@hadss/dialoghub'

export class ToastUtil {
  static show(message: string) {
    if (!message) {
      return;
    }

    const builder = DialogHub.templateManager.getToastTemplate(PresetToast.ICON_HORIZONTAL_TOAST);

    if (!builder) {
      DialogHub.getToast()
        .setTextContent(message)
        .build()
        .show();
      return;
    }

    builder
      .setTextContent(message)
  }
}