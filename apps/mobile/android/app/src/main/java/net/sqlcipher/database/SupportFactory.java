package net.sqlcipher.database;

import androidx.sqlite.db.SupportSQLiteOpenHelper;

/**
 * Bridge the legacy SQLCipher package used by WalletConnect to the maintained
 * sqlcipher-android artifact, which ships 16 KB-compatible native libraries.
 *
 * This compatibility class is required because WalletConnect still references
 * the legacy package name in compiled bytecode:
 * - com.walletconnect:android-core:1.24.0 (android-core-1.24.0.aar)
 * - classes:
 *   - com.walletconnect.android.di.CoreStorageModuleKt
 *   - com.walletconnect.android.di.CoreStorageModuleKt$coreStorageModule$1$1
 *   - com.walletconnect.android.di.CoreStorageModuleKt$sdkBaseStorageModule$1$1
 */
public final class SupportFactory implements SupportSQLiteOpenHelper.Factory {
    private final net.zetetic.database.sqlcipher.SupportOpenHelperFactory delegate;

    public SupportFactory(byte[] passphrase) {
        this(passphrase, null, true);
    }

    public SupportFactory(byte[] passphrase, SQLiteDatabaseHook hook) {
        this(passphrase, hook, true);
    }

    public SupportFactory(byte[] passphrase, SQLiteDatabaseHook hook, boolean clearPassphrase) {
        delegate = new net.zetetic.database.sqlcipher.SupportOpenHelperFactory(
            passphrase,
            adaptHook(hook),
            clearPassphrase
        );
    }

    @Override
    public SupportSQLiteOpenHelper create(SupportSQLiteOpenHelper.Configuration configuration) {
        return delegate.create(configuration);
    }

    private static net.zetetic.database.sqlcipher.SQLiteDatabaseHook adaptHook(
        SQLiteDatabaseHook hook
    ) {
        if (hook == null) {
            return null;
        }
        return new net.zetetic.database.sqlcipher.SQLiteDatabaseHook() {
            @Override
            public void preKey(net.zetetic.database.sqlcipher.SQLiteConnection connection) {
                hook.preKey(null);
            }

            @Override
            public void postKey(net.zetetic.database.sqlcipher.SQLiteConnection connection) {
                hook.postKey(null);
            }
        };
    }
}
