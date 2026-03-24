import pandas as pd
import os
import re

def is_valid_castle(name):
    """城名として不適切なノイズを除去"""
    if not isinstance(name, str): return False
    noise_patterns = [r'^\^', r'^「', r'^カテゴリ', r'一覧$', r'の城$', r'史学者$', r'に関わる団体', r'^映画']
    for p in noise_patterns:
        if re.search(p, name): return False
    return len(name) > 1

def generate_missions(spots_df):
    missions = []

    # 1. 特別なミッション: 現存十二天守 (キーワードマッチ)
    original_12 = ["弘前城", "松本城", "丸岡城", "犬山城", "彦根城", "姫路城", "松江城", "備中松山城", "丸亀城", "伊予松山城", "宇和島城", "高知城"]
    targets = spots_df[spots_df['name_ja'].apply(lambda x: any(k in x for k in original_12))]
    missions.append({
        "m_id": "m-001", "title_ja": "現存十二天守コンプリート", "title_en": "The 12 Original Castles",
        "description_ja": "日本に唯一残る12の現存天守をすべて巡る究極のミッション。", "description_en": "The ultimate goal: Visit all 12 remaining original castle towers in Japan.",
        "target_ids": ",".join(targets['spot_id'].tolist())
    })

    # 2. 武将ミッション (20件)
    warlords = [
        ("織田信長", "Oda Nobunaga", ["清洲", "岐阜", "安土", "小牧山"]),
        ("豊臣秀吉", "Toyotomi Hideyoshi", ["大坂城", "長浜", "墨俣", "伏見", "名護屋"]),
        ("徳川家康", "Tokugawa Ieyasu", ["岡崎", "浜松", "駿府", "江戸城"]),
        ("伊達政宗", "Date Masamune", ["仙台城", "青葉城", "白石城", "米沢"]),
        ("上杉謙信", "Uesugi Kenshin", ["春日山", "栃尾", "唐沢山"]),
        ("武田信玄", "Takeda Shingen", ["躑躅ヶ崎", "要害山", "高遠"]),
        ("真田家", "Sanada Clan", ["上田城", "沼田城", "名胡桃", "岩櫃"]),
        ("藤堂高虎", "Todo Takatora", ["今治城", "宇和島", "津城", "伊賀上野"]),
        ("加藤清正", "Kato Kiyomasa", ["熊本城", "名古屋城", "江戸城"]),
        ("黒田官兵衛", "Kuroda Kanbei", ["中津城", "福岡城", "姫路城"]),
    ]
    for idx, (name, en, keys) in enumerate(warlords):
        targets = spots_df[spots_df['name_ja'].apply(lambda x: any(k in x for k in keys))]
        if not targets.empty:
            missions.append({
                "m_id": f"war-{idx+1:03d}", "title_ja": f"{name}ゆかりの地", "title_en": f"Legacy of {en}",
                "description_ja": f"戦国時代を駆け抜けた{name}に関連する重要拠点を巡る。", "description_en": f"Visit the strategic strongholds associated with {en}.",
                "target_ids": ",".join(targets['spot_id'].head(5).tolist())
            })

    # 3. 都道府県ミッション (47都道府県すべて)
    for pref_id in range(1, 48):
        targets = spots_df[spots_df['pref_id'] == pref_id]
        if not targets.empty:
            p_ja = targets.iloc[0]['prefecture_ja']
            p_en = targets.iloc[0]['prefecture_en']
            missions.append({
                "m_id": f"pref-{pref_id:03d}", "title_ja": f"{p_ja}制覇への道", "title_en": f"Master of {p_en}",
                "description_ja": f"{p_ja}内にある主要な城郭を巡り、地域の歴史を体感する。", "description_en": f"Explore the major castles in {p_en} and experience local history.",
                "target_ids": ",".join(targets.sample(min(5, len(targets)))['spot_id'].tolist())
            })

    # 100件に満たない場合はランダム生成
    while len(missions) < 100:
        sample = spots_df.sample(5)
        missions.append({
            "m_id": f"rnd-{len(missions):03d}", "title_ja": f"日本名城紀行 第{len(missions)}集", "title_en": f"Japan Castle Tour Vol.{len(missions)}",
            "description_ja": "日本各地に眠る古城をランダムに巡るミッション。", "description_en": "A random journey to discover historic castle sites across Japan.",
            "target_ids": ",".join(sample['spot_id'].tolist())
        })

    return pd.DataFrame(missions).head(100)

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    df = pd.read_csv(os.path.join(script_dir, 'castles_master_simple.csv'))

    # クレンジング: 有効な城名のみ抽出し、別名は保持
    df = df[df['name_ja'].apply(is_valid_castle)]

    # 英語名の生成 (カッコ内を除去して Castle を付与)
    def to_en(name):
        base = re.sub(r'[（\(].*[）\)]', '', str(name)).strip()
        return f"{base} Castle"
    df['name_en'] = df['name_ja'].apply(to_en)

    # spots.csv 保存 (全2000件規模)
    df[['spot_id', 'name_ja', 'name_en', 'prefecture_ja', 'prefecture_en', 'pref_id']].to_csv(
        os.path.join(script_dir, 'spots.csv'), index=False)
    print(f"spots.csv generated: {len(df)} records.")

    # missions.csv 生成
    missions_df = generate_missions(df)
    missions_df.to_csv(os.path.join(script_dir, 'missions.csv'), index=False)
    print(f"missions.csv generated: {len(missions_df)} records.")
