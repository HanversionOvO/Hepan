export type ListenerDisposer = () => void;

export class ListenerManager {
  private readonly disposers: Map<string, ListenerDisposer> = new Map();

  public register(key: string, onRegister: () => void, onUnregister: ListenerDisposer): void {
    if (this.disposers.has(key)) {
      return;
    }
    onRegister();
    this.disposers.set(key, onUnregister);
  }

  public unregister(key: string): void {
    const disposer = this.disposers.get(key);
    if (!disposer) {
      return;
    }
    disposer();
    this.disposers.delete(key);
  }

  public clear(): void {
    this.disposers.forEach((disposer) => {
      disposer();
    });
    this.disposers.clear();
  }
}
