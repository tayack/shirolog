import pandas as pd
import os

# 1. パスの設定
file_path = r'C:\Users\taken\StudioProjects\shirolog\scripts\spots.csv'

def sort_spots_safely():
    if not os.path.exists(file_path):
        print(f"Error: {file_path} が見つかりません。")
        return

    # CSV読み込み（UTF-8を想定）
    # 万が一の型不一致を防ぐため、pref_idは文字列として読み込む
    df = pd.read_csv(file_path, dtype={'pref_id': str})

    # 2. 並べ替え
    # pref_id（都道府県順）を第一キー、name_ja（名前順）を第二キーにしてソート
    # pref_idが "01", "02" となっていれば、文字列ソートで正しく並びます
    df = df.sort_values(by=['pref_id', 'name_ja']).reset_index(drop=True)

    # 3. 上書き保存（BOM付きUTF-8）
    # index=False で、行番号がCSVに書き込まれないようにします
    df.to_csv(file_path, index=False, encoding='utf-8-sig')

    print(f"成功: {file_path} を都道府県順・名前順でソートして上書きしました。")
    print("※spot_id は一切変更していません。")

if __name__ == "__main__":
    sort_spots_safely()