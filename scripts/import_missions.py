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

def import_missions(db, csv_path):
    """missions.csvを読み込み、master_missionsコレクションに登録する"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    # 標準の読み込み設定
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
            'title_zh': str(row['title_zh']),
            'title_ko': str(row['title_ko']),
            'description_ja': str(row['description_ja']),
            'description_en': str(row['description_en']),
            'description_zh': str(row['description_zh']),
            'description_ko': str(row['description_ko']),
            'targetSpotIds': target_ids,
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_missions のインポートが完了しました。")

if __name__ == "__main__":
    db = initialize_firebase()
    if db:
        print("=== Firestore ミッションマスタデータ構築 ===")
        delete_collection(db, 'master_missions')

        script_dir = os.path.dirname(os.path.abspath(__file__))
        import_missions(db, os.path.join(script_dir, 'missions.csv'))

        print("=== 処理が完了しました ===")
