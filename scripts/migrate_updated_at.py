import firebase_admin
from firebase_admin import credentials, firestore
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
            print(f"エラー: '{key_path}' が見つかりません。 scripts フォルダに配置してください。")
            return None

        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Firebase初期化エラー: {e}")
        return None

def migrate_user_logs(db):
    """user_logs コレクション内のすべてのドキュメントに対し、updatedAt がなければ visitDate をコピーする"""
    print("user_logs のマイグレーションを開始します...")
    try:
        collection_ref = db.collection('user_logs')
        docs = collection_ref.stream()

        updated_count = 0
        skipped_count = 0

        # 500件ずつバッチ処理
        batch = db.batch()
        batch_count = 0

        for doc in docs:
            data = doc.to_dict()

            # updatedAt が存在しない場合のみ更新
            if 'updatedAt' not in data:
                visit_date = data.get('visitDate')
                if visit_date:
                    batch.update(doc.reference, {'updatedAt': visit_date})
                    updated_count += 1
                    batch_count += 1
                else:
                    print(f"警告: ドキュメント {doc.id} に visitDate がありません。スキップします。")
                    skipped_count += 1
            else:
                skipped_count += 1

            # Firestoreのバッチ制限（500件）に達したらコミット
            if batch_count >= 500:
                batch.commit()
                batch = db.batch()
                batch_count = 0

        if batch_count > 0:
            batch.commit()

        print(f"マイグレーション完了: {updated_count} 件を更新、{skipped_count} 件をスキップしました。")

    except Exception as e:
        print(f"マイグレーション中にエラーが発生しました: {e}")

if __name__ == "__main__":
    db = initialize_firebase()
    if db:
        print("=== Firestore user_logs マイグレーション ===")
        migrate_user_logs(db)
        print("=== 処理が終了しました ===")
