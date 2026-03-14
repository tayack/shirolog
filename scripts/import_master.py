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

def delete_collection(db, collection_name, batch_size=500):
    """指定されたコレクション内のすべてのドキュメントを削除する"""
    print(f"'{collection_name}' コレクションを削除中...")
    collection_ref = db.collection(collection_name)
    docs = collection_ref.list_documents(page_size=batch_size)
    deleted = 0

    for doc in docs:
        doc.delete()
        deleted += 1

    print(f"'{collection_name}' から {deleted} 件のドキュメントを削除しました。")

def import_spots(db, csv_path):
    """spots.csvを読み込み、master_spotsコレクションに登録する"""
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
            'name': row['name'],
            'prefecture': row['prefecture'],
            'pref_id': int(row['pref_id'])
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_spots のインポートが完了しました。")

def import_missions(db, csv_path):
    """missions.csvを読み込み、master_missionsコレクションに登録する"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    df = pd.read_csv(csv_path)
    print(f"'{csv_path}' から {len(df)} 件のミッションデータをインポート中...")

    batch = db.batch()
    for _, row in df.iterrows():
        doc_ref = db.collection('master_missions').document(row['m_id'])

        target_ids = [s.strip() for s in str(row['target_ids']).split(',')]

        # models.dart の Mission.fromFirestore が期待するキー名に合わせる
        data = {
            'm_id': row['m_id'],
            'title': row['title'],
            'targetSpotIds': target_ids,    # target_ids から変更
            'description': row['desc']      # desc から変更
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_missions のインポートが完了しました。")

if __name__ == "__main__":
    db = initialize_firebase()
    if db:
        print("--- Firestore マスターデータ構築開始 (DeleteInsert) ---")

        # 既存データの削除
        delete_collection(db, 'master_spots')
        delete_collection(db, 'master_missions')

        # CSVからのインポート
        script_dir = os.path.dirname(os.path.abspath(__file__))
        import_spots(db, os.path.join(script_dir, 'spots.csv'))
        import_missions(db, os.path.join(script_dir, 'missions.csv'))

        print("--- すべての処理が正常に完了しました ---")
