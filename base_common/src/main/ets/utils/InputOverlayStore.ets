const INPUT_OVERLAY_TAG = '[InputOverlayStore]: ';

export const InputOverlayVisibilityEvent = 'inputOverlayVisibility';

type InputOverlayListener = (visible: boolean) => void;

class SimpleEventBus {
  private listeners: Map<string, Set<Function>> = new Map();

  on(event: string, listener: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)?.add(listener);
  }

  off(event: string, listener: Function) {
    this.listeners.get(event)?.delete(listener);
  }

  emit<T>(event: string, payload: T) {
    this.listeners.get(event)?.forEach(listener => {
      try {
        listener(payload);
      } catch (error) {
        console.error(INPUT_OVERLAY_TAG, `Emit event ${event} failed: ${JSON.stringify(error)}`);
      }
    });
  }
}

export const InputOverlayStore = new SimpleEventBus();

export function onInputOverlayVisibility(listener: InputOverlayListener) {
  InputOverlayStore.on(InputOverlayVisibilityEvent, listener);
}

export function offInputOverlayVisibility(listener: InputOverlayListener) {
  InputOverlayStore.off(InputOverlayVisibilityEvent, listener);
}
