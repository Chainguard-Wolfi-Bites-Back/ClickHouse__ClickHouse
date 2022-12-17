#pragma once

#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <vector>
#include <base/types.h>
#include <Interpreters/Context_fwd.h>
#include <Common/Throttler_fwd.h>
#include <Storages/HeaderCollection.h>

#include <IO/S3Common.h>

namespace Poco::Util
{
class AbstractConfiguration;
}

namespace DB
{

struct Settings;
class NamedCollection;

struct S3Settings
{
    struct RequestSettings
    {
        struct PartUploadSettings
        {
            size_t min_upload_part_size = 16 * 1024 * 1024;
            size_t max_upload_part_size = 5ULL * 1024 * 1024 * 1024;
            size_t upload_part_size_multiply_factor = 2;
            size_t upload_part_size_multiply_parts_count_threshold = 500;
            size_t max_part_number = 10000;
            size_t max_single_part_upload_size = 32 * 1024 * 1024;
            size_t max_single_operation_copy_size = 5ULL * 1024 * 1024 * 1024;

            inline bool operator==(const PartUploadSettings & other) const
            {
                return min_upload_part_size == other.min_upload_part_size
                    && max_upload_part_size == other.max_upload_part_size
                    && upload_part_size_multiply_factor == other.upload_part_size_multiply_factor
                    && upload_part_size_multiply_parts_count_threshold == other.upload_part_size_multiply_parts_count_threshold
                    && max_part_number == other.max_part_number
                    && max_single_part_upload_size == other.max_single_part_upload_size
                    && max_single_operation_copy_size == other.max_single_operation_copy_size;
            }

            void updateFromSettings(const Settings & settings) { updateFromSettingsImpl(settings, true); }
            void validate();

        private:
            PartUploadSettings() = default;
            explicit PartUploadSettings(const Settings & settings);
            explicit PartUploadSettings(const NamedCollection & collection);
            PartUploadSettings(const Poco::Util::AbstractConfiguration & config, const String & key, const Settings & settings);

            void updateFromSettingsImpl(const Settings & settings, bool if_changed);

            friend struct RequestSettings;
        };

    private:
        PartUploadSettings upload_settings = {};

    public:
        size_t max_single_read_retries = 4;
        size_t max_connections = 1024;
        bool check_objects_after_upload = false;
        size_t max_unexpected_write_error_retries = 4;
        ThrottlerPtr get_request_throttler;
        ThrottlerPtr put_request_throttler;

        const PartUploadSettings & getUploadSettings() const { return upload_settings; }

        inline bool operator==(const RequestSettings & other) const
        {
            return upload_settings == other.upload_settings
                && max_single_read_retries == other.max_single_read_retries
                && max_connections == other.max_connections
                && check_objects_after_upload == other.check_objects_after_upload
                && max_unexpected_write_error_retries == other.max_unexpected_write_error_retries
                && get_request_throttler == other.get_request_throttler
                && put_request_throttler == other.put_request_throttler;
        }

        RequestSettings() = default;
        explicit RequestSettings(const Settings & settings);
        explicit RequestSettings(const NamedCollection & collection);
        RequestSettings(const Poco::Util::AbstractConfiguration & config, const String & key, const Settings & settings);

        void updateFromSettings(const Settings & settings);

    private:
        void updateFromSettingsImpl(const Settings & settings, bool if_changed);
    };

    S3::AuthSettings auth_settings;
    RequestSettings request_settings;

    inline bool operator==(const S3Settings & other) const
    {
        return auth_settings == other.auth_settings && request_settings == other.request_settings;
    }
};

/// Settings for the StorageS3.
class StorageS3Settings
{
public:
    void loadFromConfig(const String & config_elem, const Poco::Util::AbstractConfiguration & config, const Settings & settings);

    S3Settings getSettings(const String & endpoint) const;

private:
    mutable std::mutex mutex;
    std::map<const String, const S3Settings> s3_settings;
};

}
