-- DSpace Database Initialization Script
-- This script sets up the basic DSpace database structure

-- Create extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create basic DSpace tables structure
-- Note: This is a simplified version - DSpace will create the full schema during installation

-- EPerson table (users)
CREATE TABLE IF NOT EXISTS eperson (
    eperson_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(64) UNIQUE NOT NULL,
    can_log_in BOOLEAN DEFAULT TRUE,
    require_certificate BOOLEAN DEFAULT FALSE,
    self_registered BOOLEAN DEFAULT FALSE,
    last_active TIMESTAMP,
    sub_frequency INTEGER DEFAULT -1,
    password VARCHAR(255),
    salt VARCHAR(255),
    digest_algorithm VARCHAR(255),
    netid VARCHAR(255),
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- EPerson Group table
CREATE TABLE IF NOT EXISTS epersongroup (
    eperson_group_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    permanent BOOLEAN DEFAULT FALSE,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Community table
CREATE TABLE IF NOT EXISTS community (
    community_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_description TEXT,
    introductory_text TEXT,
    copyright_text TEXT,
    side_bar_text TEXT,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Collection table
CREATE TABLE IF NOT EXISTS collection (
    collection_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_description TEXT,
    introductory_text TEXT,
    copyright_text TEXT,
    side_bar_text TEXT,
    license TEXT,
    provenance TEXT,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Item table
CREATE TABLE IF NOT EXISTS item (
    item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    in_archive BOOLEAN DEFAULT FALSE,
    withdrawn BOOLEAN DEFAULT FALSE,
    discoverable BOOLEAN DEFAULT TRUE,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bitstream table
CREATE TABLE IF NOT EXISTS bitstream (
    bitstream_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    description TEXT,
    source VARCHAR(255),
    checksum VARCHAR(64),
    checksum_algorithm VARCHAR(32),
    size_bytes BIGINT,
    deleted BOOLEAN DEFAULT FALSE,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Metadata table for Dublin Core
CREATE TABLE IF NOT EXISTS metadatavalue (
    metadata_value_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID REFERENCES item(item_id),
    metadata_field_id INTEGER,
    text_value TEXT,
    text_lang VARCHAR(24),
    confidence INTEGER DEFAULT -1,
    place INTEGER DEFAULT 0,
    authority VARCHAR(255),
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Handle table
CREATE TABLE IF NOT EXISTS handle (
    handle_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    handle VARCHAR(255) UNIQUE NOT NULL,
    resource_type_id INTEGER,
    resource_id UUID,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_eperson_email ON eperson(email);
CREATE INDEX IF NOT EXISTS idx_eperson_netid ON eperson(netid);
CREATE INDEX IF NOT EXISTS idx_epersongroup_name ON epersongroup(name);
CREATE INDEX IF NOT EXISTS idx_community_name ON community(name);
CREATE INDEX IF NOT EXISTS idx_collection_name ON collection(name);
CREATE INDEX IF NOT EXISTS idx_item_archive ON item(in_archive);
CREATE INDEX IF NOT EXISTS idx_item_withdrawn ON item(withdrawn);
CREATE INDEX IF NOT EXISTS idx_item_discoverable ON item(discoverable);
CREATE INDEX IF NOT EXISTS idx_bitstream_name ON bitstream(name);
CREATE INDEX IF NOT EXISTS idx_bitstream_deleted ON bitstream(deleted);
CREATE INDEX IF NOT EXISTS idx_metadatavalue_item ON metadatavalue(item_id);
CREATE INDEX IF NOT EXISTS idx_handle_handle ON handle(handle);

-- Insert initial admin user
INSERT INTO eperson (email, can_log_in, self_registered, password, salt, digest_algorithm)
VALUES (
    'admin@dspace.org',
    TRUE,
    FALSE,
    'admin', -- This will be properly hashed by DSpace
    'salt',
    'MD5'
) ON CONFLICT (email) DO NOTHING;

-- Insert admin group
INSERT INTO epersongroup (name, permanent)
VALUES ('Administrator', TRUE)
ON CONFLICT (name) DO NOTHING;

-- Insert basic communities
INSERT INTO community (name, short_description)
VALUES 
    ('DSpace Community', 'Main community for DSpace repository'),
    ('Research Publications', 'Research publications and papers'),
    ('Theses and Dissertations', 'Student theses and dissertations')
ON CONFLICT DO NOTHING;

-- Insert basic collections
INSERT INTO collection (name, short_description)
VALUES 
    ('General Collection', 'General items and documents'),
    ('Research Papers', 'Research papers and publications'),
    ('Student Works', 'Student projects and assignments')
ON CONFLICT DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dspace;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dspace;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO dspace;
