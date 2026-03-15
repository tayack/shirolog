import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import os

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
    """指定されたコレクション内のすべてのドキュメントを削除する (Delete処理)"""
    print(f"'{collection_name}' コレクションを削除中...")
    try:
        collection_ref = db.collection(collection_name)
        # ドキュメントを1件ずつ削除（マスターデータ規模ならこれで十分）
        docs = collection_ref.list_documents()
        deleted = 0
        for doc in docs:
            doc.delete()
            deleted += 1
        print(f"'{collection_name}' から {deleted} 件の古いデータを削除しました。")
    except Exception as e:
        print(f"'{collection_name}' の削除中にエラーが発生しました（無視して継続します）: {e}")

def import_spots(db, csv_path):
    """spots.csvを読み込み、master_spotsコレクションに登録する (Insert処理)"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    df = pd.read_csv(csv_path)
    print(f"'{csv_path}' から {len(df)} 件のスポットデータをインポート中...")

    batch = db.batch()
    for _, row in df.iterrows():
        doc_ref = db.collection('master_spots').document(row['spot_id'])
        data = {
            'spot_id': row['spot_id'],
            'name_ja': row['name_ja'],
            'name_en': row['name_en'],
            'prefecture_ja': row['prefecture_ja'],
            'prefecture_en': row['prefecture_en'],
            'pref_id': int(row['pref_id'])
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_spots のインポートが完了しました。")

def import_missions(db, csv_path):
    """missions.csvを読み込み、master_missionsコレクションに登録する (Insert処理)"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    df = pd.read_csv(csv_path)
    print(f"'{csv_path}' から {len(df)} 件のミッションデータをインポート中...")

    batch = db.batch()
    for _, row in df.iterrows():
        doc_ref = db.collection('master_missions').document(row['m_id'])

        target_ids = [s.strip() for s in str(row['target_ids']).split(',')]

        data = {
            'm_id': row['m_id'],
            'title_ja': row['title_ja'],
            'title_en': row['title_en'],
            'description_ja': row['description_ja'],
            'description_en': row['description_en'],
            'targetSpotIds': target_ids,
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_missions のインポートが完了しました。")

if __name__ == "__main__":
    db = initialize_firebase()
    if db:
        print("=== Firestore マスターデータ構築 (Delete-Insert 方式) ===")

        # 1. 既存データをすべて削除 (Delete)
        delete_collection(db, 'master_spots')
        delete_collection(db, 'master_missions')

        # 2. CSVの内容をすべて登録 (Insert)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        import_spots(db, os.path.join(script_dir, 'spots.csv'))
        import_missions(db, os.path.join(script_dir, 'missions.csv'))

        print("=== すべての処理が正常に完了しました ===")
