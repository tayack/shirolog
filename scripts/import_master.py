import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import os
import csv

# ---------------------------------------------------------
# 設定: Firebase コンソールから取得した秘密鍵のパス
# ---------------------------------------------------------
SERVICE_ACCOUNT_KEY = 'shirolog_service_account.json'

def initialize_firebase():
    """Firebaseの初期化を行い、Firestoreクライアントを返す"""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        key_path = os.path.join(script_dir, SERVICE_ACCOUNT_KEY)

        if not os.path.exists(key_path):
            print(f"エラー: '{key_path}' が見つかりません。")
            return None

        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Firebase初期化エラー: {e}")
        return None

def delete_collection(db, collection_name):
    """指定されたコレクション内のすべてのドキュメントを削除する"""
    print(f"'{collection_name}' コレクションを削除中...")
    try:
        collection_ref = db.collection(collection_name)
        docs = collection_ref.list_documents()
        deleted = 0
        for doc in docs:
            doc.delete()
            deleted += 1
        print(f"'{collection_name}' から {deleted} 件の古いデータを削除しました。")
    except Exception as e:
        print(f"'{collection_name}' の削除中にエラーが発生しました: {e}")

def import_spots(db, csv_path):
    """spots.csvを読み込み、master_spotsコレクションに登録する"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    # dtypeを指定して、pref_idが意図せず浮動小数になるのを防ぐ
    df = pd.read_csv(csv_path, encoding='utf-8', dtype={'pref_id': str})
    print(f"'{csv_path}' から {len(df)} 件のスポットデータをインポート中...")

    batch = db.batch()
    count = 0
    for _, row in df.iterrows():
        doc_ref = db.collection('master_spots').document(str(row['spot_id']))
        data = {
            'spot_id': str(row['spot_id']),
            'name_ja': str(row['name_ja']),
            'name_en': str(row['name_en']) if pd.notna(row['name_en']) else '',
            'prefecture_ja': str(row['prefecture_ja']),
            'prefecture_en': str(row['prefecture_en']),
            'pref_id': str(row['pref_id']).zfill(2) # 常に2桁の文字列にする
        }
        batch.set(doc_ref, data)
        count += 1
        if count % 500 == 0:
            batch.commit()
            batch = db.batch()

    batch.commit()
    print("master_spots のインポートが完了しました。")

def import_missions(db, csv_path):
    """missions.csvを読み込み、master_missionsコレクションに登録する"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    # 標準の読み込み設定に戻す（引用符は自動で扱われる）
    df = pd.read_csv(csv_path, encoding='utf-8')
    print(f"'{csv_path}' から {len(df)} 件のミッションデータをインポート中...")

    batch = db.batch()
    for _, row in df.iterrows():
        doc_ref = db.collection('master_missions').document(str(row['m_id']))

        # カンマ区切りの文字列をリストに変換
        target_ids = [s.strip() for s in str(row['target_ids']).split(',') if s.strip()]

        data = {
            'm_id': str(row['m_id']),
            'title_ja': str(row['title_ja']),
            'title_en': str(row['title_en']),
            'description_ja': str(row['description_ja']),
            'description_en': str(row['description_en']),
            'targetSpotIds': target_ids,
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_missions のインポートが完了しました。")

if __name__ == "__main__":
    db = initialize_firebase()
    if db:
        print("=== Firestore マスターデータ構築 ===")
        delete_collection(db, 'master_spots')
        delete_collection(db, 'master_missions')

        script_dir = os.path.dirname(os.path.abspath(__file__))
        import_spots(db, os.path.join(script_dir, 'spots.csv'))
        import_missions(db, os.path.join(script_dir, 'missions.csv'))

        print("=== すべての処理が正常に完了しました ===")
