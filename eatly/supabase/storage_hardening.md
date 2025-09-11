Supabase Storage güvenlik notları

1) Bucket erişimi
- `food_images` bucket'ını Private yapın (Dashboard → Storage → Bucket → Make private).
- Public URL üretimini kapatın; uygulama yalnızca `createSignedUrl` ile imzalı URL kullanır.

2) Policy örneği (opsiyonel)
Storage için RLS yerine, erişim imzalı URL ile sınırlandırılmalıdır. Ekstra kontrol için edge function/proxy kullanabilirsiniz.

3) İstemci kodu
- `PhotoService.fetchTodayPhotoUrls` sadece imzalı URL döner.
- Public URL kayıtları kaldırıldı.

4) Key rotation
- Service role key'i istemciye koymayın.
- Anon key'i sızma riski halinde döndürün.


