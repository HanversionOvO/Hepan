export class UrlUtil {
  public static buildUrl(baseUrl: string, path: string): string {
    const trimmedPath = path.trim();
    if (trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://')) {
      return trimmedPath;
    }

    const trimmedBase = baseUrl.trim();
    const normalizedBase = trimmedBase.endsWith('/') ? trimmedBase.slice(0, -1) : trimmedBase;
    if (!trimmedPath) {
      return normalizedBase;
    }

    const normalizedPath = trimmedPath.startsWith('/') ? trimmedPath : `/${trimmedPath}`;
    return `${normalizedBase}${normalizedPath}`;
  }
}
